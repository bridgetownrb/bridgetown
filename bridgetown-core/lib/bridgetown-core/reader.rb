# frozen_string_literal: true

module Bridgetown
  class Reader
    # @return [Bridgetown::Site]
    attr_reader :site

    # @param site [Bridgetown::Site]
    def initialize(site)
      @site = site
    end

    # Read Site data from disk and load it into internal data structures.
    #
    # Returns nothing.
    def read
      site.defaults_reader.read
      read_layouts
      read_directories
      read_includes
      sort_files!
      site.data = site.collections.data.read.merge_data_resources
      read_collections
      Bridgetown::PluginManager.source_manifests.select(&:content).each do |manifest|
        PluginContentReader.new(site, manifest).read
      end
    end

    def read_layouts
      site.layouts = LayoutReader.new(site).read
    end

    def read_collections
      site.collections.each_value do |collection|
        next if collection.data?

        collection.read
      end
    end

    # Sorts generated pages and static files.
    def sort_files!
      site.generated_pages.sort_by!(&:name)
      site.static_files.sort_by!(&:relative_path)
    end

    # Recursively traverse directories to find pages and static files
    # that will become part of the site according to the rules in
    # filter_entries.
    #
    # dir - The String relative path of the directory to read. Default: ''.
    #
    # Returns nothing.
    def read_directories(dir = "")
      base = site.in_source_dir(dir)

      return unless File.directory?(base)

      dot_dirs = []
      dot_pages = []
      dot_static_files = []

      dot = Dir.chdir(base) { filter_entries(Dir.entries("."), base) }
      dot.each do |entry|
        file_path = @site.in_source_dir(base, entry)
        if File.directory?(file_path)
          dot_dirs << entry
        elsif Utils.has_yaml_header?(file_path) || Utils.has_rbfm_header?(file_path)
          dot_pages << entry
        else
          dot_static_files << entry
        end
      end

      retrieve_dirs(base, dir, dot_dirs)
      retrieve_pages(dir, dot_pages)
      retrieve_static_files(dir, dot_static_files)
    end

    # Recursively traverse directories with the read_directories function.
    #
    # base - The String representing the site's base directory.
    # dir - The String representing the directory to traverse down.
    # dot_dirs - The Array of subdirectories in the dir.
    #
    # Returns nothing.
    def retrieve_dirs(_base, dir, dot_dirs)
      dot_dirs.each do |file|
        dir_path = site.in_source_dir(dir, file)
        rel_path = File.join(dir, file)
        read_directories(rel_path) unless @site.destination.chomp("/") == dir_path
      end
    end

    # Retrieve all the pages from the current directory,
    # add them to the site and sort them.
    #
    # dir - The String representing the directory retrieve the pages from.
    # dot_pages - The Array of pages in the dir.
    #
    # Returns nothing.
    def retrieve_pages(dir, dot_pages)
      dot_pages.each do |page_path|
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
    # entries - The Array of String file/directory entries to filter.
    # base_directory - The string representing the optional base directory.
    #
    # Returns the Array of filtered entries.
    def filter_entries(entries, base_directory = nil)
      EntryFilter.new(site, base_directory: base_directory).filter(entries)
    end

    # Read the entries from a particular directory for processing
    #
    # dir - The String representing the relative path of the directory to read.
    # subfolder - The String representing the directory to read.
    #
    # Returns the list of entries to process
    def get_entries(dir, subfolder)
      base = site.in_source_dir(dir, subfolder)
      return [] unless File.exist?(base)

      entries = Dir.chdir(base) { filter_entries(Dir["**/*"], base) }
      entries.delete_if { |e| File.directory?(site.in_source_dir(base, e)) }
    end

    private

    # Internal
    #
    # Determine if the directory is supposed to contain posts.
    # If the user has defined a custom collections_dir, then attempt to read
    # posts only from within that directory.
    #
    # Returns true if a custom collections_dir has been set but current directory lies
    # outside that directory.
    def outside_configured_directory?(dir)
      collections_dir = site.config["collections_dir"]
      !collections_dir.empty? && !dir.start_with?("/#{collections_dir}")
    end

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
