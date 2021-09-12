# frozen_string_literal: true

module Bridgetown
  class Collection
    # @return [Bridgetown::Site]
    attr_reader :site

    attr_reader :label, :metadata
    attr_writer :docs

    attr_writer :resources

    # Create a new Collection.
    #
    # @param site [Bridgetown::Site] the site to which this collection belongs
    # @param label [String] the name of the collection
    def initialize(site, label)
      @site     = site
      @label    = sanitize_label(label)
      @metadata = extract_metadata
    end

    def builtin?
      label.in? %w(posts pages data).freeze
    end

    def legacy_reader?
      label.in? %w(posts data).freeze
    end

    def data?
      label == "data"
    end

    # Fetch the Documents in this collection.
    # Defaults to an empty array if no documents have been read in.
    #
    # @return [Array<Bridgetown::Document>]
    def docs
      @docs ||= []
    end

    # Fetch the Resources in this collection.
    # Defaults to an empty array if no resources have been read in.
    #
    # @return [Array<Bridgetown::Resource::Base>]
    def resources
      @resources ||= []
    end

    # Fetch the collection resources and arrange them by slug in a hash.
    #
    # @return [Hash<String, Bridgetown::Resource::Base>]
    def resources_by_slug
      resources.group_by { |item| item.data.slug }.transform_values(&:first)
    end

    # Fetch the collection resources and arrange them by relative URL in a hash.
    #
    # @return [Hash<String, Bridgetown::Resource::Base>]
    def resources_by_relative_url
      resources.group_by(&:relative_url).transform_values(&:first)
    end

    # Iterate over either Resources or Documents depending on how the site is
    # configured
    def each(&block)
      site.uses_resource? ? resources.each(&block) : docs.each(&block)
    end

    # Fetch the static files in this collection.
    # Defaults to an empty array if no static files have been read in.
    #
    # @return [Array<Bridgetown::StaticFile>]
    def static_files
      @static_files ||= []
    end

    def files
      Bridgetown::Deprecator.deprecation_message "Collection#files is now Collection#static_files"
      static_files
    end

    # Read the allowed documents into the collection's array of docs.
    #
    # @return [Bridgetown::Collection] self
    def read # rubocop:todo Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      filtered_entries.each do |file_path|
        full_path = collection_dir(file_path)
        next if File.directory?(full_path)

        if site.uses_resource?
          next if File.basename(file_path).starts_with?("_")

          if label == "data" || Utils.has_yaml_header?(full_path) ||
              Utils.has_rbfm_header?(full_path)
            read_resource(full_path)
          else
            read_static_file(file_path, full_path)
          end
        elsif Utils.has_yaml_header? full_path
          read_document(full_path)
        else
          read_static_file(file_path, full_path)
        end
      end
      site.static_files.concat(static_files)
      sort_docs!

      self
    end

    # All the entries in this collection.
    #
    # @return [Array<String>] file paths to the documents in this collection
    #   relative to the collection's folder
    def entries
      return [] unless exists?

      @entries ||= begin
        collection_dir_slash = "#{collection_dir}/"
        Utils.safe_glob(collection_dir, ["**", "*"], File::FNM_DOTMATCH).map do |entry|
          entry.sub(collection_dir_slash, "")
        end
      end
    end

    # Filtered version of the entries in this collection.
    # See `Bridgetown::EntryFilter#filter` for more information.
    #
    # @return [Array<String>] list of filtered entry paths
    def filtered_entries
      return [] unless exists?

      @filtered_entries ||=
        Dir.chdir(absolute_path) do
          entry_filter.filter(entries).reject do |f|
            path = collection_dir(f)
            File.directory?(path)
          end
        end
    end

    # The folder name of this Collection, e.g. `_posts` or `_events`
    #
    # @return [String]
    def folder_name
      @folder_name ||= "_#{label}"
    end
    alias_method :relative_directory, :folder_name

    # The relative path to the folder containing the collection.
    #
    # @return [String] folder where the collection is stored relative to the
    #   configured collections folder (usually the site source)
    def relative_path
      Pathname.new(container).join(folder_name).to_s
    end

    # The full path to the folder containing the collection.
    #
    # @return [String] full path where the collection is stored on the filesystem
    def absolute_path
      @absolute_path ||= site.in_source_dir(relative_path)
    end
    alias_method :directory, :absolute_path

    # The full path to the folder containing the collection, with
    #   optional subpaths.
    #
    # @param *files [Array<String>] any other path pieces relative to the
    #   folder to append to the path
    # @return [String]
    def collection_dir(*files)
      return absolute_path if files.empty?

      site.in_source_dir(relative_path, *files)
    end

    # Checks whether the folder "exists" for this collection.
    #
    # @return [Boolean]
    def exists?
      File.directory?(absolute_path)
    end

    # The entry filter for this collection.
    # Creates an instance of Bridgetown::EntryFilter if needed.
    #
    # @return [Bridgetown::EntryFilter]
    def entry_filter
      @entry_filter ||= Bridgetown::EntryFilter.new(
        site,
        base_directory: folder_name,
        include_underscores: site.uses_resource?
      )
    end

    # An inspect string.
    #
    # @return [String]
    def inspect
      "#<#{self.class} @label=#{label} docs=#{docs} resources=#{resources}>"
    end

    # Produce a sanitized label name
    # Label names may not contain anything but alphanumeric characters,
    #   underscores, and hyphens.
    #
    # @param label [String] the possibly-unsafe label
    # @return [String] sanitized version of the label.
    def sanitize_label(label)
      label.gsub(%r![^a-z0-9_\-\.]!i, "")
    end

    # Produce a representation of this Collection for use in Liquid.
    # Exposes two attributes:
    #   - label
    #   - docs
    #
    # @return [Bridgetown::Drops::CollectionDrop] representation of this
    #   collection for use in Liquid
    def to_liquid
      Drops::CollectionDrop.new self
    end

    # Whether the collection's documents ought to be written as individual
    #   files in the output.
    #
    # @return [Boolean] true if the 'write' metadata is true, false otherwise.
    def write?
      !!metadata.fetch("output", false)
    end

    # Used by Resource's permalink processor
    # @return [String]
    def default_permalink
      metadata.fetch("permalink") do
        "/:collection/:path/"
      end
    end

    # LEGACY: The URL template to render collection's documents at.
    #
    # @return [String]
    def url_template
      @url_template ||= metadata.fetch("permalink") do
        Utils.add_permalink_suffix("/:collection/:path", site.permalink_style)
      end
    end

    # Extract options for this collection from the site configuration.
    #
    # @return [HashWithDotAccess::Hash]
    def extract_metadata
      site.config.collections[label] || HashWithDotAccess::Hash.new
    end

    def merge_data_resources # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      data_contents = {}

      sanitize_filename = ->(name) do
        name.gsub(%r![^\w\s-]+|(?<=^|\b\s)\s+(?=$|\s?\b)!, "")
          .gsub(%r!\s+!, "_")
      end

      resources.each do |data_resource|
        segments = data_resource.relative_path.each_filename.to_a[1..-1]
        nested = []
        segments.each_with_index do |segment, index|
          sanitized_segment = sanitize_filename.(File.basename(segment, ".*"))
          hsh = nested.empty? ? data_contents : data_contents.dig(*nested)
          if !hsh.is_a?(Hash)
            Bridgetown.logger.error(
              "Error:",
              "#{nested.join("/")} is not a Hash structure, #{segment} cannot be read"
            )
          elsif index == segments.length - 1
            hsh[sanitized_segment] = data_resource.data.rows || data_resource.data
          elsif !hsh.key?(sanitized_segment)
            hsh[sanitized_segment] = {}
          end
          nested << sanitized_segment
        end
      end

      merge_environment_specific_metadata(data_contents).with_dot_access
    end

    def merge_environment_specific_metadata(data_contents)
      if data_contents["site_metadata"]
        data_contents["site_metadata"][Bridgetown.environment]&.each_key do |k|
          data_contents["site_metadata"][k] =
            data_contents["site_metadata"][Bridgetown.environment][k]
        end
        data_contents["site_metadata"].delete(Bridgetown.environment)
      end

      data_contents
    end

    # Read in resource from repo path
    # @param full_path [String]
    def read_resource(full_path)
      id = "repo://#{label}.collection/" + Addressable::URI.escape(
        Pathname(full_path).relative_path_from(Pathname(site.source)).to_s
      )
      resource = Bridgetown::Model::Base.find(id).to_resource.read!
      resources << resource if site.config.unpublished || resource.published?
    end

    private

    def container
      @container ||= site.config["collections_dir"]
    end

    def read_document(full_path)
      doc = Document.new(full_path, site: site, collection: self).tap(&:read)
      docs << doc if site.config.unpublished || doc.published?
    end

    def sort_docs!
      if metadata["sort_by"].is_a?(String)
        sort_docs_by_key!
        sort_resources_by_key!
      else
        docs.sort!
        resources.sort!
      end
      docs.reverse! if metadata.sort_direction == "descending"
      resources.reverse! if metadata.sort_direction == "descending"
    end

    # A custom sort function based on Schwartzian transform
    # Refer https://byparker.com/blog/2017/schwartzian-transform-faster-sorting/ for details
    def sort_docs_by_key!
      meta_key = metadata["sort_by"]
      # Modify `docs` array to cache document's property along with the Document instance
      docs.map! { |doc| [doc.data[meta_key], doc] }.sort! do |apples, olives|
        order = determine_sort_order(meta_key, apples, olives)

        # Fall back to `Document#<=>` if the properties were equal or were non-sortable
        # Otherwise continue with current sort-order
        if order.nil? || order.zero?
          apples[-1] <=> olives[-1]
        else
          order
        end

        # Finally restore the `docs` array with just the Document objects themselves
      end.map!(&:last)
    end

    def sort_resources_by_key!
      meta_key = metadata["sort_by"]
      # Modify `docs` array to cache document's property along with the Document instance
      resources.map! { |doc| [doc.data[meta_key], doc] }.sort! do |apples, olives|
        order = determine_sort_order(meta_key, apples, olives)

        # Fall back to `Document#<=>` if the properties were equal or were non-sortable
        # Otherwise continue with current sort-order
        if order.nil? || order.zero?
          apples[-1] <=> olives[-1]
        else
          order
        end

        # Finally restore the `docs` array with just the Document objects themselves
      end.map!(&:last)
    end

    def determine_sort_order(sort_key, apples, olives)
      apple_property, apple_document = apples
      olive_property, olive_document = olives

      if apple_property.nil? && !olive_property.nil?
        order_with_warning(sort_key, apple_document, 1)
      elsif !apple_property.nil? && olive_property.nil?
        order_with_warning(sort_key, olive_document, -1)
      else
        apple_property <=> olive_property
      end
    end

    def order_with_warning(sort_key, document, order)
      Bridgetown.logger.warn "Sort warning:", "'#{sort_key}' not defined in" \
                              " #{document.relative_path}"
      order
    end

    def read_static_file(file_path, full_path)
      relative_dir = Bridgetown.sanitized_path(
        relative_path,
        File.dirname(file_path)
      ).chomp("/.")

      static_files << StaticFile.new(
        site,
        site.source,
        relative_dir,
        File.basename(full_path),
        self
      )
    end
  end
end
