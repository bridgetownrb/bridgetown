# frozen_string_literal: true

module Bridgetown
  class Page
    include DataAccessible
    include LayoutPlaceable
    include LiquidRenderable
    include Publishable
    include Validatable

    attr_writer :dir
    attr_accessor :site, :pager, :paginator
    attr_accessor :name, :ext, :basename
    attr_accessor :data, :content, :output

    alias_method :extname, :ext

    # A set of extensions that are considered HTML or HTML-like so we
    # should not alter them,  this includes .xhtml through XHTM5.

    HTML_EXTENSIONS = %w(
      .html
      .xhtml
      .htm
    ).freeze

    # Initialize a new Page.
    #
    # site - The Site object.
    # base - The String path to the source.
    # dir  - The String path between the source and the file.
    # name - The String filename of the file.
    # from_plugin - true if the Page file is located in a Gem-based plugin folder
    # rubocop:disable Metrics/ParameterLists
    def initialize(site, base, dir, name, from_plugin: false)
      @site = site
      @base = base
      @dir  = dir
      @name = name
      @path = if from_plugin
                File.join(base, dir, name)
              else
                site.in_source_dir(base, dir, name)
              end

      process(name)
      read_yaml(PathManager.join(base, dir), name)

      data.default_proc = proc do |_, key|
        site.frontmatter_defaults.find(relative_path, type, key)
      end

      Bridgetown::Hooks.trigger :pages, :post_init, self
    end
    # rubocop:enable Metrics/ParameterLists

    # The generated directory into which the page will be placed
    # upon generation. This is derived from the permalink or, if
    # permalink is absent, will be '/'
    #
    # Returns the String destination directory.
    def dir
      if url.end_with?("/")
        url
      else
        url_dir = File.dirname(url)
        url_dir.end_with?("/") ? url_dir : "#{url_dir}/"
      end
    end

    def liquid_drop
      @liquid_drop ||= begin
        defaults = site.frontmatter_defaults.all(relative_path, type)
        unless defaults.empty?
          Utils.deep_merge_hashes!(data, Utils.deep_merge_hashes!(defaults, data))
        end
        Drops::PageDrop.new(self)
      end
    end

    # Public
    #
    # Liquid representation of current page
    def to_liquid
      liquid_drop
    end

    # The full path and filename of the post. Defined in the YAML of the post
    # body.
    #
    # Returns the String permalink or nil if none has been set.
    def permalink
      data.nil? ? nil : data["permalink"]
    end

    # The template of the permalink.
    #
    # Returns the template String.
    def template
      if !html?
        "/:path/:basename:output_ext"
      elsif index?
        "/:path/"
      else
        Utils.add_permalink_suffix("/:path/:basename", site.permalink_style)
      end
    end

    # The generated relative url of this page. e.g. /about.html.
    #
    # Returns the String url.
    def url
      @url ||= URL.new(
        template: template,
        placeholders: url_placeholders,
        permalink: permalink
      ).to_s
    end

    # Returns a hash of URL placeholder names (as symbols) mapping to the
    # desired placeholder replacements. For details see "url.rb"
    def url_placeholders
      {
        path: @dir,
        basename: basename,
        output_ext: output_ext,
      }
    end

    # Extract information from the page filename.
    #
    # name - The String filename of the page file.
    #
    # NOTE: `String#gsub` removes all trailing periods (in comparison to `String#chomp`)
    # Returns nothing.
    def process(name)
      self.ext = File.extname(name)
      self.basename = name[0..-ext.length - 1].gsub(%r!\.*\z!, "")
    end

    # The path to the source file
    #
    # Returns the path to the source file
    def path
      data.fetch("path") { relative_path }
    end

    # The path to the page source file, relative to the site source
    def relative_path
      @relative_path ||= File.join(*[@dir, @name].map(&:to_s).reject(&:empty?)).delete_prefix("/")
    end

    # FIXME: spinning up a new Renderer object just to get an extension
    # seems excessive
    #
    # The output extension of the page.
    #
    # Returns the output extension
    def output_ext
      @output_ext ||= Bridgetown::Renderer.new(site, self).output_ext
    end

    # Obtain destination path.
    #
    # dest - The String path to the destination dir.
    #
    # Returns the destination file path String.
    def destination(dest)
      path = site.in_dest_dir(dest, URL.unescape_path(url))
      path = File.join(path, "index") if url.end_with?("/")
      path << output_ext unless path.end_with? output_ext
      path
    end

    # Write the generated page file to the destination directory.
    #
    # dest - The String path to the destination dir.
    #
    # Returns nothing.
    def write(dest)
      path = destination(dest)
      FileUtils.mkdir_p(File.dirname(path))
      Bridgetown.logger.debug "Writing:", path
      File.write(path, output, mode: "wb")
      Bridgetown::Hooks.trigger :pages, :post_write, self
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
      Bridgetown::Hooks.trigger :pages, hook_name, self, *args
    end

    def type
      :pages
    end

    def write?
      true
    end
  end
end
