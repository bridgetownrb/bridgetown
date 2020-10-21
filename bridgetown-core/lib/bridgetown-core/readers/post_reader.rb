# frozen_string_literal: true

module Bridgetown
  class PostReader
    attr_reader :site, :unfiltered_content

    def initialize(site)
      @site = site
    end

    # Read all the files in <source>/<dir>/_posts and create a new Document
    # object with each one.
    #
    # dir - The String relative path of the directory to read.
    #
    # Returns nothing.
    def read_posts(dir)
      read_publishable(dir, "_posts", Document::DATE_FILENAME_MATCHER)
    end

    # Read all the files in <source>/<dir>/<magic_dir> and create a new
    # Document object with each one insofar as it matches the regexp matcher.
    #
    # dir - The String relative path of the directory to read.
    #
    # Returns nothing.
    def read_publishable(dir, magic_dir, matcher)
      read_content(dir, magic_dir, matcher)
        .tap { |entries| entries.select { |entry| entry.respond_to?(:read) }.each(&:read) }
        .select { |entry| processable?(entry) }
    end

    # Read all the content files from <source>/<dir>/magic_dir
    #   and return them with the type klass.
    #
    # dir - The String relative path of the directory to read.
    # magic_dir - The String relative directory to <dir>,
    #   looks for content here.
    # klass - The return type of the content.
    #
    # Returns klass type of content files
    def read_content(dir, magic_dir, matcher)
      @site.reader.get_entries(dir, magic_dir).map do |entry|
        path = @site.in_source_dir(File.join(dir, magic_dir, entry))

        if matcher.match?(entry) || Utils.has_yaml_header?(path)
          # Process as Document
          Document.new(path,
                       site: @site,
                       collection: @site.posts)
        else
          # Process as Static File
          read_static_file(
            path,
            File.join(dir, magic_dir, File.dirname(entry).sub(".", ""))
          )
        end
      end.reject(&:nil?)
    end

    private

    def read_static_file(full_path, relative_dir)
      StaticFile.new(
        site,
        site.source,
        relative_dir,
        File.basename(full_path),
        @site.posts
      )
    end

    def processable?(doc)
      return true if doc.is_a?(StaticFile)

      if doc.content.nil?
        Bridgetown.logger.debug "Skipping:", "Content in #{doc.relative_path} is nil"
        false
      elsif !doc.content.valid_encoding?
        Bridgetown.logger.debug "Skipping:", "#{doc.relative_path} is not valid UTF-8"
        false
      else
        publishable?(doc)
      end
    end

    def publishable?(doc)
      site.publisher.publish?(doc).tap do |will_publish|
        if !will_publish && site.publisher.hidden_in_the_future?(doc)
          Bridgetown.logger.warn "Skipping:", "#{doc.relative_path} has a future date"
        end
      end
    end
  end
end
