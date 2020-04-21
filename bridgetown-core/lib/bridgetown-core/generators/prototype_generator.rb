# frozen_string_literal: true

module Bridgetown
  class PrototypeGenerator < Generator
    priority :low

    def generate(site)
      @site = site
      @configured_collection = "posts"

      prototype_pages = site.pages.select do |page|
        page.data["prototype"].is_a?(Hash)
      end

      if prototype_pages.length.positive?
        site.pages.reject! do |page|
          prototype_pages.include? page
        end

        prototype_pages.each do |prototype_page|
          search_term = validate_search_term(prototype_page)
          next if search_term.nil?

          terms_matching_pages(search_term).each do |term|
            generate_new_page_from_prototype(prototype_page, search_term, term).data
          end
        end
      end
    end

    def validate_search_term(prototype_page)
      search_term = prototype_page.data["prototype"]["term"]
      return nil unless search_term.is_a?(String)

      if prototype_page.data["prototype"]["collection"]
        @configured_collection = prototype_page.data["prototype"]["collection"]
      end

      # Categories and Tags are unique in that singular and plural front matter
      # can be present for each
      search_term.sub(%r!^category$!, "categories").sub(%r!^tag$!, "tags")
    end

    def generate_new_page_from_prototype(prototype_page, search_term, term)
      new_page = PrototypePage.new(prototype_page)
      # Use the original specified term so we get "tag" back, not "tags":
      new_page.data[prototype_page.data["prototype"]["term"]] = term

      process_title_data_placeholder(new_page, prototype_page, search_term, term)
      process_title_simple_placeholders(new_page, prototype_page, term)

      new_page.data["pagination"] = {} unless new_page.data["pagination"].is_a?(Hash)
      new_page.data["pagination"]["enabled"] = true
      new_page.data["pagination"]["collection"] = @configured_collection
      new_page.data["pagination"]["where_query"] = [search_term, term]
      new_page.slugify_term(term)
      @site.pages << new_page
      new_page
    end

    def terms_matching_pages(search_term)
      selected_docs = @site.documents.select do |document|
        document.respond_to?(:collection) && document.collection.label == @configured_collection
      end

      Bridgetown::Paginate::Generator::PaginationIndexer.index_documents_by(
        selected_docs, search_term
      ).keys
    end

    def process_title_data_placeholder(new_page, prototype_page, search_term, term)
      if prototype_page["prototype"]["data"]
        if new_page.data["title"]&.include?(":prototype-data-label")
          related_data = @site.data[prototype_page["prototype"]["data"]].dig(term)
          if related_data
            new_page.data["#{search_term}_data"] = related_data
            data_label = related_data[prototype_page["prototype"]["data_label"]]
            new_page.data["title"] = new_page.data["title"].gsub(
              ":prototype-data-label", data_label
            )
          end
        end
      end
    end

    def process_title_simple_placeholders(new_page, _prototype_page, term)
      if new_page.data["title"]&.include?(":prototype-term-titleize")
        new_page.data["title"] = new_page.data["title"].gsub(
          ":prototype-term-titleize", Bridgetown::Utils.titleize_slug(term)
        )
      end

      if new_page.data["title"]&.include?(":prototype-term")
        new_page.data["title"] = new_page.data["title"].gsub(
          ":prototype-term", term
        )
      end
    end
  end

  class PrototypePage < Page
    def initialize(prototype_page)
      @site = prototype_page.site
      @url = ""
      @name = "index.html"
      @path = prototype_page.path

      process(@name)

      self.data = Bridgetown::Utils.deep_merge_hashes prototype_page.data, {}
      self.content = prototype_page.content

      # Perform some validation that is also performed in Bridgetown::Page
      validate_data! prototype_page.path
      validate_permalink! prototype_page.path

      @dir = Pathname.new(prototype_page.relative_path).dirname.to_s
      @path = site.in_source_dir(@dir, @name)
    end

    def slugify_term(term)
      term_slug = Bridgetown::Utils.slugify(term)
      @url = "/#{@dir}/#{term_slug}/"
    end
  end
end
