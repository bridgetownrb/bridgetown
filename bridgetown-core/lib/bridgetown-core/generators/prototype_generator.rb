# frozen_string_literal: true

Bridgetown::Hooks.register :pages, :post_init, reloadable: false do |page|
  if page.class != Bridgetown::PrototypePage && page.data["prototype"].is_a?(Hash)
    Bridgetown::PrototypeGenerator.add_matching_template(page)
  end
end

module Bridgetown
  class PrototypeGenerator < Generator
    priority :low

    @matching_templates = []

    def self.add_matching_template(template)
      @matching_templates << template
    end

    class << self
      attr_reader :matching_templates
    end

    def generate(site)
      @site = site
      @configured_collection = "posts"

      prototype_pages = self.class.matching_templates.select do |page|
        site.pages.include? page
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
      new_page = PrototypePage.new(prototype_page, @configured_collection, search_term, term)
      @site.pages << new_page
      new_page
    end

    # TODO: this would be a great use of .try
    # document.try(:collection).try(:label) == @configured_collection
    def terms_matching_pages(search_term)
      selected_docs = @site.documents.select do |document|
        document.respond_to?(:collection) && document.collection.label == @configured_collection
      end

      Bridgetown::Paginate::PaginationIndexer.index_documents_by(
        selected_docs, search_term
      ).keys
    end
  end

  class PrototypePage < Page
    def initialize(prototype_page, collection, search_term, term)
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

      process_prototype_page_data(prototype_page, collection, search_term, term)

      Bridgetown::Hooks.trigger :pages, :post_init, self
    end

    def process_prototype_page_data(prototype_page, collection, search_term, term)
      # Fill in pagination details to be handled later by Bridgetown::Paginate
      data["pagination"] = Bridgetown::Utils.deep_merge_hashes(
        prototype_page.data["pagination"].to_h, {
          "enabled"     => true,
          "collection"  => collection,
          "where_query" => [search_term, term],
        }
      )
      # Use the original prototype page term so we get "tag" back, not "tags":
      data[prototype_page.data["prototype"]["term"]] = term
      # Process title and slugs/URLs:
      process_title_data_placeholder(prototype_page, search_term, term)
      process_title_simple_placeholders(term)
      slugify_term(term)
    end

    def process_title_data_placeholder(prototype_page, search_term, term)
      if prototype_page["prototype"]["data"]
        if data["title"]&.include?(":prototype-data-label")
          related_data = @site.data[prototype_page["prototype"]["data"]].dig(term)
          if related_data
            data["#{search_term}_data"] = related_data
            data_label = related_data[prototype_page["prototype"]["data_label"]]
            data["title"] = data["title"].gsub(
              ":prototype-data-label", data_label
            )
          end
        end
      end
    end

    def process_title_simple_placeholders(term)
      if data["title"]&.include?(":prototype-term-titleize")
        data["title"] = data["title"].gsub(
          ":prototype-term-titleize", Bridgetown::Utils.titleize_slug(term)
        )
      end

      if data["title"]&.include?(":prototype-term")
        data["title"] = data["title"].gsub(
          ":prototype-term", term
        )
      end
    end

    def slugify_term(term)
      term_slug = Bridgetown::Utils.slugify(term)
      @url = if permalink.is_a?(String)
               data["permalink"] = data["permalink"].sub(":term", term_slug)
             else
               "/#{@dir}/#{term_slug}/"
             end
    end
  end
end
