# frozen_string_literal: true

module Bridgetown
  class StaticFile
    using Bridgetown::Refinements
    extend Forwardable

    attr_reader :relative_path, :extname, :name, :data, :site, :collection

    def_delegator :to_liquid, :to_json, :to_json

    class << self
      # The cache of last modification times [path] -> mtime.
      def mtimes
        @mtimes ||= {}
      end

      def reset_cache
        @mtimes = nil
      end
    end

    # Initialize a new StaticFile.
    #
    # @param site [Bridgetown::Site]
    # @param base [String] path to the <source>.
    # @param dir [String] path between <source> and the file.
    # @param name [String] filename of the file.
    # @param collection [Bridgetown::Collection] optional collection the file is attached to
    def initialize(site, base, dir, name, collection = nil) # rubocop:disable Metrics/ParameterLists
      @site = site
      @base = base
      @dir  = dir
      @name = name
      @collection = collection
      @relative_path = File.join(*[@dir, @name].compact)
      @extname = File.extname(@name)
      @data = @site.frontmatter_defaults.all(relative_path, type).as_dots
      data.permalink ||= if collection && !collection.builtin?
                           "#{collection.default_permalink.chomp("/").chomp(".*")}.*"
                         else
                           "/:path.*"
                         end
    end

    # Returns source file path.
    def path
      @path ||= File.join(*[@base, @dir, @name].compact)
    end

    # Obtain destination path
    #
    # @param dest [String] path to the destination dir
    # @return [String]
    def destination(dest)
      dest = site.in_dest_dir(dest)
      dest_url = url
      if site.base_path.present? && collection
        dest_url = dest_url.delete_prefix site.base_path(strip_slash_only: true)
      end
      site.in_dest_dir(dest, Bridgetown::Utils.unencode_uri(dest_url))
    end

    def destination_rel_dir
      if @collection
        File.dirname(url)
      else
        @dir
      end
    end

    def modified_time
      @modified_time ||= File.stat(path).mtime
    end

    alias_method :date, :modified_time

    # @return [Integer] last modification time for this file
    def mtime
      modified_time.to_i
    end

    # Is source path modified?
    #
    # @return [Boolean] true if modified since last write
    def modified?
      self.class.mtimes[path] != mtime
    end

    # Whether to write the file to the filesystem
    #
    # @return [Boolean] true unless the defaults for the destination path contain `published: false`
    def write?
      publishable = defaults.fetch("published", true)
      return publishable unless @collection

      publishable && @collection.write?
    end

    # Write the static file to the destination directory (if modified)
    #
    # @param dest [String] path to the destination dir
    # @return [Boolean] false if the file was not modified since last time (no-op)
    def write(dest) # rubocop:disable Naming/PredicateMethod
      dest_path = destination(dest)
      return false if File.exist?(dest_path) && !modified?

      self.class.mtimes[path] = mtime

      FileUtils.mkdir_p(File.dirname(dest_path))
      FileUtils.rm_rf(dest_path)
      Bridgetown.logger.debug "Saving file:", dest_path
      copy_file(dest_path)

      true
    end

    def to_liquid
      @to_liquid ||= Drops::StaticFileDrop.new(self)
    end

    def basename
      @basename ||= File.basename(name, ".*")
    end

    alias_method :basename_without_ext, :basename

    def relative_path_basename_without_prefix
      return_path = Pathname.new("")
      Pathname.new(cleaned_relative_path).each_filename do |filename|
        return_path += filename unless filename.starts_with?("_")
      end

      (return_path.dirname + return_path.basename(".*")).to_s
    end

    def placeholders
      {
        collection: @collection.label,
        path: cleaned_relative_path,
        output_ext: "",
        name: "",
        title: "",
      }
    end

    # Generates a relative path with the collection's directory removed when applicable
    #   and additionally removes any multiple periods in the string.
    #
    # NOTE: `String#gsub!` removes all trailing periods (in comparison to `String#chomp!`)
    #
    # @example
    #   When `relative_path` is "_methods/site/my-cool-avatar...png":
    #     cleaned_relative_path
    #     # => "/site/my-cool-avatar"
    #
    # @return [String] cleaned relative path of the static file
    def cleaned_relative_path
      @cleaned_relative_path ||= begin
        cleaned = relative_path[0..(-extname.length - 1)]
        cleaned.gsub!(%r!\.*\z!, "")
        cleaned.sub!(@collection.relative_path, "") if @collection
        cleaned
      end
    end

    # Applies a similar URL-building technique as resources that takes
    # the collection's URL template into account. The default URL template can
    # be overridden in the collection's configuration
    def url
      @url ||= begin
        newly_processed = false
        base = if @collection.nil?
                 cleaned_relative_path
               else
                 newly_processed = true
                 Bridgetown::Resource::PermalinkProcessor.new(self).transform
               end.to_s.chomp("/")
        newly_processed ? base : "#{base}#{extname}"
      end
    end
    alias_method :relative_url, :url

    # @return [Symbol, nil] type of the collection if present
    def type
      @type ||= @collection&.label&.to_sym
    end

    # @return [Hash] front matter defaults defined for the file's URL and/or type
    def defaults
      @defaults ||= site.frontmatter_defaults.all url, type
    end

    # @return [String] includes only the relative path of the object
    def inspect
      "#<#{self.class} @relative_path=#{relative_path.inspect}>"
    end

    private

    def copy_file(dest_path)
      FileUtils.copy_entry(path, dest_path)

      return if File.symlink?(dest_path)

      File.utime(self.class.mtimes[path], self.class.mtimes[path], dest_path)
    end
  end
end
