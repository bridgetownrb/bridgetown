# frozen_string_literal: true

module Bridgetown
  class Layout
    include DataAccessible
    include FrontMatterImporter
    include LiquidRenderable

    # Gets the Site object.
    attr_reader :site

    # Gets the name of this layout.
    attr_reader :name

    # Gets the path to this layout.
    attr_reader :path

    # Gets the path to this layout relative to its base
    attr_reader :relative_path

    # Gets/Sets the extension of this layout.
    attr_accessor :ext

    alias_method :extname, :ext

    # Gets/Sets the Hash that holds the metadata for this layout.
    attr_accessor :data

    # Gets/Sets the content of this layout.
    # @return [String]
    attr_accessor :content

    # @return [Integer]
    attr_accessor :front_matter_line_count

    # Gets/Sets the current document (for layout-compatible converters)
    attr_accessor :current_document

    # Gets/Sets the document output (for layout-compatible converters)
    attr_accessor :current_document_output

    # Initialize a new Layout.
    #
    # site - The Site.
    # base - The String path to the source.
    # name - The String filename of the layout file.
    # from_plugin - true if the layout comes from a Gem-based plugin folder.
    def initialize(site, base, name, from_plugin: false)
      @site = site
      @base = base
      @name = name

      if from_plugin
        @base_dir = base.sub("/layouts", "")
        @path = File.join(base, name)
      else
        @base_dir = site.source
        @path = site.in_source_dir(base, name)
      end
      @relative_path = @path.sub(@base_dir, "")
      @ext = File.extname(name)

      @data = read_front_matter(@path).with_dot_access
    rescue SyntaxError => e
      Bridgetown.logger.error "Error:",
                              "Ruby Exception in #{e.message}"
    rescue StandardError => e
      handle_read_error(e)
    ensure
      @data ||= HashWithDotAccess::Hash.new
    end

    def handle_read_error(error)
      if error.is_a? Psych::SyntaxError
        Bridgetown.logger.warn "YAML Exception reading #{@path}: #{error.message}"
      else
        Bridgetown.logger.warn "Error reading file #{@path}: #{error.message}"
      end

      if site.config["strict_front_matter"] ||
          error.is_a?(Bridgetown::Errors::FatalException)
        raise error
      end
    end

    # The inspect string for this document.
    # Includes the relative path and the collection label.
    #
    # Returns the inspect string for this document.
    def inspect
      "#<#{self.class} #{@path}>"
    end

    # Provide this Layout's data to a Hash suitable for use by Liquid.
    #
    # Returns the Hash representation of this Layout.
    def to_liquid
      data
    end
  end
end
