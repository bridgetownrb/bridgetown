# frozen_string_literal: true

module Bridgetown
  class GeneratedPage
    include LayoutPlaceable
    include Localizable
    include Publishable
    include Transformable

    attr_writer :dir
    attr_accessor :site, :paginator, :name, :ext, :basename,
                  :data, :content, :output, :original_resource

    # @return [Boolean]
    attr_reader :fast_refresh_order

    alias_method :extname, :ext

    # A set of extensions that are considered HTML or HTML-like so we
    # should not alter them

    HTML_EXTENSIONS = %w(
      .html
      .xhtml
      .htm
    ).freeze

    # Initialize a new GeneratedPage
    #
    # @param site [Bridgetown::Site]
    # @param base [String] path to the source
    # @param dir [String] path between the source and the file
    # @param name [String] filename of the file.
    # @param from_plugin [Boolean] true if the Page file is located in a Gem-based plugin folder
    # rubocop:disable Metrics/ParameterLists
    def initialize(site, base, dir, name, from_plugin: false)
      @site = site
      @base = base
      @dir  = dir
      @name = name
      @ext = File.extname(name)
      @basename = File.basename(name, ".*")
      @path = from_plugin ? File.join(base, dir, name) : site.in_source_dir(base, dir, name)

      process

      self.data ||= HashWithDotAccess::Hash.new

      Bridgetown::Hooks.trigger :generated_pages, :post_init, self
    end
    # rubocop:enable Metrics/ParameterLists

    # Returns the contents as a String.
    def to_s
      output || content || ""
    end

    # Accessor for data properties by Liquid
    #
    # @param property [String] name of the property to retrieve
    #
    # @return [Object]
    def [](property)
      data[property]
    end

    # @return [Array<Bridgetown::Slot>]
    def slots
      @slots ||= []
    end

    # The generated directory into which the page will be placed
    # upon generation. This is derived from the permalink or, if
    # permalink is absent, will be '/'
    #
    # @return [String]
    def dir
      if url.end_with?("/")
        url
      else
        url_dir = File.dirname(url)
        url_dir.end_with?("/") ? url_dir : "#{url_dir}/"
      end
    end

    # Liquid representation of current page
    #
    # @return [Bridgetown::Drops::GeneratedPageDrop]
    def to_liquid
      @liquid_drop ||= Drops::GeneratedPageDrop.new(self)
    end

    # The full path and filename of the post. Defined in the YAML of the post
    # body
    def permalink
      data&.permalink
    end

    def add_permalink_suffix(template, permalink_style)
      template = template.dup

      case permalink_style
      when :pretty, :simple
        template << "/"
      else
        template << "/" if permalink_style.to_s.end_with?("/")
        template << ":output_ext" if permalink_style.to_s.end_with?(".*")
      end

      template
    end

    # The template of the permalink.
    #
    # @return [String]
    def template
      if !html?
        "/:dir/:basename:output_ext"
      elsif index?
        "/:dir/"
      else
        add_permalink_suffix("/:dir/:basename", site.permalink_style)
      end
    end

    # The generated relative url of this page. e.g. /about.html.
    #
    # @return [String]
    def url
      return @url if @url

      tmpl = permalink || template
      placeholders = { dir: @dir, basename:, output_ext: }

      results = placeholders.inject(tmpl) do |result, token|
        break result if result.index(":").nil?

        if token.last.nil?
          # Remove leading "/" to avoid generating urls with `//`
          result.gsub("/:#{token.first}", "")
        else
          result.gsub(":#{token.first}", token.last)
        end
      end.then { Addressable::URI.normalize_component _1 }

      @url = "/#{results.sub("#", "%23")}".gsub("..", "/").gsub("./", "").squeeze("/")
    end
    alias_method :relative_url, :url

    # Layout associated with this resource
    # This will output a warning if the layout can't be found.
    #
    # @return [Bridgetown::Layout]
    def layout
      return @layout if @layout
      return if no_layout?

      @layout = site.layouts[data.layout].tap do |layout|
        unless layout
          Bridgetown.logger.warn "Generated Page:", "Layout '#{data.layout}' " \
                                                    "requested via #{relative_path} does not exist."
        end
      end
    end

    # Overide this in subclasses for custom initialization behavior
    def process
      # no-op by default
    end

    # The path to the source file
    def path
      # TODO: is this trip really necessary?!
      data.fetch("path") { relative_path }
    end

    # The path to the page source file, relative to the site source
    def relative_path
      @relative_path ||= File.join(*[@dir, @name].map(&:to_s).reject(&:empty?)).delete_prefix("/")
    end

    # The output extension of the page.
    #
    # @return [String]
    def output_ext
      @output_ext ||= permalink_ext || converter_output_ext
    end

    def permalink_ext
      page_permalink = permalink
      if page_permalink &&
          !page_permalink.end_with?("/")
        permalink_ext = File.extname(page_permalink)
        permalink_ext unless permalink_ext.empty?
      end
    end

    def converter_output_ext
      if output_exts.size == 1
        output_exts.last
      else
        output_exts[-2]
      end
    end

    def output_exts
      @output_exts ||= converters.filter_map do |c|
        c.output_ext(extname)
      end
    end

    # @return [Array<Bridgetown::Converter>]
    def converters
      @converters ||= site.matched_converters_for_convertible(self)
    end

    def transform! # rubocop:todo Metrics
      Bridgetown.logger.debug "Transforming:", relative_path

      internal_error = nil
      Signalize.effect do
        if !@fast_refresh_order && @previously_transformed_content
          self.content = @previously_transformed_content
          mark_for_fast_refresh! if site.config.fast_refresh && write?
          next
        end

        trigger_hooks :pre_render
        @previously_transformed_content ||= content
        self.content = transform_content(self)
        place_in_layout? ? place_into_layouts : self.output = content.dup
        trigger_hooks :post_render
      rescue StandardError, SyntaxError => e
        internal_error = e
      end

      raise internal_error if internal_error

      self
    end

    def place_into_layouts
      Bridgetown.logger.debug "Placing in Layouts:", relative_path
      rendered_output = content.dup

      site.validated_layouts_for(self, data.layout).each do |layout|
        rendered_output = transform_with_layout(layout, rendered_output, self)
      end

      self.output = rendered_output
    end

    # Obtain destination path.
    #
    # @param dest [String] path to the destination dir
    #
    # @return [String]
    def destination(dest)
      path = site.in_dest_dir(dest, Utils.unencode_uri(url))
      path = File.join(path, "index") if url.end_with?("/")
      path << output_ext unless path.end_with? output_ext
      path
    end

    # Write the generated page file to the destination directory.
    #
    # @param dest [String] path to the destination dir
    def write(dest)
      path = destination(dest)
      FileUtils.mkdir_p(File.dirname(path))
      Bridgetown.logger.debug "Writing:", path
      File.write(path, output, mode: "wb")
      unmark_for_fast_refresh!
      Bridgetown::Hooks.trigger :generated_pages, :post_write, self
    end

    # Returns the object as a debug String.
    def inspect
      "#<#{self.class} #{relative_path}>"
    end

    # Returns the Boolean of whether this Page is HTML or not.
    def html?
      HTML_EXTENSIONS.include?(output_ext)
    end

    # Returns the Boolean of whether this Page is an index file or not.
    def index?
      basename == "index"
    end

    def trigger_hooks(hook_name, *args)
      Bridgetown::Hooks.trigger :generated_pages, hook_name, self, *args
    end

    def type
      :generated_pages
    end

    def write?
      true
    end

    def mark_for_fast_refresh!
      @fast_refresh_order = site.fast_refresh_ordering
      site.fast_refresh_ordering += 1
    end

    def unmark_for_fast_refresh!
      @fast_refresh_order = nil
      original_resource&.unmark_for_fast_refresh!
    end
  end
end
