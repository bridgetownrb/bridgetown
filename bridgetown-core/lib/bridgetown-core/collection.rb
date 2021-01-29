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
    # site - the site to which this collection belongs.
    # label - the name of the collection
    #
    # Returns nothing.
    def initialize(site, label)
      @site     = site
      @label    = sanitize_label(label)
      @metadata = extract_metadata
    end

    def special?
      label.in? %w(posts pages data).freeze
    end

    # Fetch the Documents in this collection.
    # Defaults to an empty array if no documents have been read in.
    #
    # Returns an array of Bridgetown::Document objects.
    def docs
      @docs ||= []
    end

    # @return [Array<Bridgetown::Resource::Base>]
    def resources
      @resources ||= []
    end

    def each(&block)
      site.uses_resource? ? resources.each(&block) : docs.each(&block)
    end

    # Fetch the static files in this collection.
    # Defaults to an empty array if no static files have been read in.
    #
    # Returns an array of Bridgetown::StaticFile objects.
    def static_files
      @static_files ||= []
    end

    def files
      Bridgetown::Deprecator.deprecation_message "Collection#files is now Collection#static_files"
      static_files
    end

    # Read the allowed documents into the collection's array of docs.
    #
    # Returns the sorted array of docs.
    def read
      filtered_entries.each do |file_path|
        full_path = collection_dir(file_path)
        next if File.directory?(full_path)

        if site.uses_resource?
          if label == "data" || Utils.has_yaml_header?(full_path)
            read_resource(full_path)
          else
            read_static_file(file_path, full_path)
          end
        else
          if Utils.has_yaml_header? full_path
            read_document(full_path)
          else
            read_static_file(file_path, full_path)
          end
        end
      end
      site.static_files.concat(static_files)
      sort_docs!
    end

    # All the entries in this collection.
    #
    # Returns an Array of file paths to the documents in this collection
    #   relative to the collection's directory
    def entries
      return [] unless exists?

      @entries ||= begin
        collection_dir_slash = "#{collection_dir}/"
        Utils.safe_glob(collection_dir, ["**", "*"], File::FNM_DOTMATCH).map do |entry|
          entry[collection_dir_slash] = ""
          entry
        end
      end
    end

    # Filtered version of the entries in this collection.
    # See `Bridgetown::EntryFilter#filter` for more information.
    #
    # Returns a list of filtered entry paths.
    def filtered_entries
      return [] unless exists?

      @filtered_entries ||=
        Dir.chdir(directory) do
          entry_filter.filter(entries).reject do |f|
            path = collection_dir(f)
            File.directory?(path) || entry_filter.symlink?(f)
          end
        end
    end

    # The directory for this Collection, relative to the site source or the directory
    # containing the collection.
    #
    # Returns a String containing the directory name where the collection
    #   is stored on the filesystem.
    def relative_directory
      @relative_directory ||= "_#{label}"
    end

    # The relative path to the directory containing the collection.
    #
    # Returns a String containing the directory name where the collection
    #   is stored relative to the source directory
    def relative_path
      Pathname.new(container).join(relative_directory).to_s
    end

    # The full path to the directory containing the collection.
    #
    # Returns a String containing the directory name where the collection
    #   is stored on the filesystem.
    def directory
      @directory ||= site.in_source_dir(relative_path)
    end

    # The full path to the directory containing the collection, with
    #   optional subpaths.
    #
    # *files - (optional) any other path pieces relative to the
    #           directory to append to the path
    #
    # Returns a String containing th directory name where the collection
    #   is stored on the filesystem.
    def collection_dir(*files)
      return directory if files.empty?

      site.in_source_dir(container, relative_directory, *files)
    end

    # Checks whether the directory "exists" for this collection.
    def exists?
      File.directory?(directory)
    end

    # The entry filter for this collection.
    # Creates an instance of Bridgetown::EntryFilter.
    #
    # Returns the instance of Bridgetown::EntryFilter for this collection.
    def entry_filter
      @entry_filter ||= Bridgetown::EntryFilter.new(
        site,
        base_directory: relative_directory,
        include_underscores: site.uses_resource?
      )
    end

    # An inspect string.
    #
    # Returns the inspect string
    def inspect
      "#<#{self.class} @label=#{label} docs=#{docs} resources=#{resources}>"
    end

    # Produce a sanitized label name
    # Label names may not contain anything but alphanumeric characters,
    #   underscores, and hyphens.
    #
    # label - the possibly-unsafe label
    #
    # Returns a sanitized version of the label.
    def sanitize_label(label)
      label.gsub(%r![^a-z0-9_\-\.]!i, "")
    end

    # Produce a representation of this Collection for use in Liquid.
    # Exposes two attributes:
    #   - label
    #   - docs
    #
    # Returns a representation of this collection for use in Liquid.
    def to_liquid
      Drops::CollectionDrop.new self
    end

    # Whether the collection's documents ought to be written as individual
    #   files in the output.
    #
    # Returns true if the 'write' metadata is true, false otherwise.
    def write?
      !!metadata.fetch("output", false)
    end

    # Used by Resource's permalink processor
    # @return [String]
    def default_permalink
      metadata.fetch("permalink") do
        "/:collection/:path/index.*"
      end
    end

    # The URL template to render collection's documents at.
    #
    # Returns the URL template to render collection's documents at.
    def url_template
      @url_template ||= metadata.fetch("permalink") do
        Utils.add_permalink_suffix("/:collection/:path", site.permalink_style)
      end
    end

    # Extract options for this collection from the site configuration.
    #
    # Returns the metadata for this collection
    def extract_metadata
      if site.config["collections"].is_a?(Hash)
        site.config["collections"][label] || {}
      else
        {}
      end
    end

    def merge_data_resources
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
          hsh[sanitized_segment] = if index == segments.length - 1
                                     data_resource.data.array || data_resource.data
                                   else
                                     {}
                                   end
          nested << sanitized_segment
        end
      end

      data_contents.with_dot_access
    end

    private

    def container
      @container ||= site.config["collections_dir"]
    end

    def read_document(full_path)
      doc = Document.new(full_path, site: site, collection: self)
      doc.read
      docs << doc if site.unpublished || doc.published?
    end

    def read_resource(full_path)
      resource = Bridgetown::Resource::Base.new(
        site: site,
        origin: Bridgetown::Resource::FileOrigin.new(
          collection: self,
          original_path: full_path
        )
      )
      resource.read
      resources << resource if site.unpublished || resource.published?
    end

    def sort_docs!
      if metadata["sort_by"].is_a?(String)
        sort_docs_by_key!
        sort_resources_by_key!
      else
        docs.sort!
        resources.sort!
      end
      docs.reverse! if metadata.sort_order == "descending"
      resources.reverse! if metadata.sort_order == "descending"
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
