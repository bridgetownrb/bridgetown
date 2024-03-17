# frozen_string_literal: true

module Bridgetown
  class Reader
    # @return [Bridgetown::Site]
    attr_reader :site

    # @param site [Bridgetown::Site]
    def initialize(site)
      @site = site
    end

    # Read data and resources from disk and load it into internal data structures.
    # @return [void]
    def read
      site.defaults_reader.read
      site.data = site.collections.data.read.merge_data_resources
      read_layouts
      read_directories
      read_includes
      sort_files!
      read_collections
      site.config.source_manifests.select(&:content).each do |manifest|
        PluginContentReader.new(site, manifest).read
      end
    end

    # Read in layouts
    # @see LayoutReader
    # @return [void]
    def read_layouts
      site.layouts = LayoutReader.new(site).read
    end

    # Read in collections (other than the data collection)
    # @return [void]
    def read_collections
      site.collections.each_value do |collection|
        next if collection.data?

        collection.read unless site.ssr? && collection.metadata.skip_for_ssr
      end
    end

    # Sorts generated pages and static files.
    # @return [void]
    def sort_files!
      site.generated_pages.sort_by!(&:name)
      site.static_files.sort_by!(&:relative_path)
    end

    # Recursively traverse directories to find pages and static files
    # that will become part of the site according to the rules in
    # filter_entries.
    #
    # @param dir [String] relative path of the directory to read. Default: ''
    # @return [void]
    def read_directories(dir = "")
      base = site.in_source_dir(dir)

      return unless File.directory?(base)

      entries_dirs = []
      entries_pages = []
      entries_static_files = []

      entries = Dir.chdir(base) { filter_entries(Dir.entries("."), base) }
      entries.each do |entry|
        file_path = @site.in_source_dir(base, entry)
        if File.directory?(file_path)
          entries_dirs << entry
        elsif FrontMatter::Loaders.front_matter?(file_path)
          entries_pages << entry
        else
          entries_static_files << entry
        end
      end

      retrieve_dirs(dir, entries_dirs)
      retrieve_pages(dir, entries_pages)
      retrieve_static_files(dir, entries_static_files) unless site.ssr?
    end

    # Recursively traverse directories with the read_directories function.
    #
    # @param dir [String] the directory to traverse down
    # @param entries_dirs [Array<String>] subdirectories in the directory
    # @return [void]
    def retrieve_dirs(dir, entries_dirs)
      entries_dirs.each do |file|
        dir_path = site.in_source_dir(dir, file)
        rel_path = File.join(dir, file)
        read_directories(rel_path) unless @site.destination.chomp("/") == dir_path
      end
    end

    # Retrieve all the pages from the current directory,
    # add them to the site and sort them.
    #
    # @param dir [String] the directory to retrieve the pages from
    # @param entries_pages [Array<String>] page paths in the directory
    # @return [void]
    def retrieve_pages(dir, entries_pages)
      return if site.ssr? && site.collections.pages.metadata.skip_for_ssr

      entries_pages.each do |page_path|
        site.collections.pages.read_resource(site.in_source_dir(dir, page_path))
      end
    end

    # Retrieve all the static files from the current directory,
    # add them to the site and sort them.
    #
    # @param dir [String] The directory retrieve the static files from.
    # @param files [Array<String>] The static files in the dir.
    def retrieve_static_files(dir, files)
      site.static_files.concat(
        files.map do |file|
          StaticFile.new(site, site.source, dir, file)
        end
      )
    end

    # Filter out any files/directories that are hidden or backup files (start
    # with "." or "#" or end with "~"), or contain site content (start with "_"),
    # or are excluded in the site configuration, unless they are web server
    # files such as '.htaccess'.
    #
    # @param entries [Array<String>] file/directory entries to filter
    # @param base_directory [String] optional base directory
    #
    # Returns the Array of filtered entries.
    def filter_entries(entries, base_directory = nil)
      EntryFilter.new(site, base_directory:).filter(entries)
    end

    # Read the entries from a particular directory for processing
    #
    # @param dir [String] parent directory
    # @param subfolder [String] the directory to read
    #
    # Returns the list of entries to process
    def get_entries(dir, subfolder)
      base = site.in_source_dir(dir, subfolder)
      return [] unless File.exist?(base)

      entries = Dir.chdir(base) { filter_entries(Dir["**/*"], base) }
      entries.delete_if { |e| File.directory?(site.in_source_dir(base, e)) }
    end

    private

    def read_includes
      site.config.include.each do |entry|
        next if entry == ".htaccess"

        entry_path = site.in_source_dir(entry)
        next if File.directory?(entry_path)

        read_included_file(entry_path) if File.file?(entry_path)
      end
    end

    def read_included_file(entry_path)
      dir  = File.dirname(entry_path).sub(site.source, "")
      file = Array(File.basename(entry_path))
      retrieve_static_files(dir, file)
    end
  end
end
