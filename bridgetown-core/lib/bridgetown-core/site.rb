# frozen_string_literal: true

module Bridgetown
  class Site
    require_all "bridgetown-core/concerns/site"

    include Configurable
    include Content
    include Extensible
    include Localizable
    include Processable
    include Renderable
    include Writable

    attr_reader   :root_dir, :source, :dest, :cache_dir, :config,
                  :regenerator, :liquid_renderer, :components_load_paths,
                  :includes_load_paths

    # All files not pages/documents or structured data in the source folder
    # @return [Array<StaticFile>]
    attr_accessor :static_files

    # @return [Array<Layout>]
    attr_accessor :layouts

    # @return [Array<Page>]
    attr_accessor :pages

    # @return [Boolean]
    attr_accessor :fast_render_mode
    def fast_render_mode?
      fast_render_mode == true
    end

    # NOTE: Eventually pages will be deprecated once the Resource content engine
    # is default
    alias_method :generated_pages, :pages

    attr_accessor :exclude, :include, :lsi, :highlighter, :permalink_style,
                  :time, :future, :unpublished, :limit_posts,
                  :keep_files, :baseurl, :data, :file_read_opts,
                  :plugin_manager, :converters, :generators, :reader

    def self.start(overrides = {})
      new(Bridgetown.configuration(overrides))
    end

    # Public: Initialize a new Site.
    #
    # config - A Hash containing site configuration details.
    def initialize(config)
      self.config = config
      locale

      @plugin_manager  = PluginManager.new(self)
      @cleaner         = Cleaner.new(self)
      @reader          = Reader.new(self)
      @regenerator     = Regenerator.new(self)
      @liquid_renderer = LiquidRenderer.new(self)

      ensure_not_in_dest

      Bridgetown::Current.site = self
      Bridgetown::Hooks.trigger :site, :after_init, self

      reset   # Processable
      setup   # Extensible
    end

    def fast_render(origin_id)
      self.fast_render_mode = true
      Bridgetown::Hooks.trigger :site, :pre_read, self
      defaults_reader.tap do |d|
        d.path_defaults.clear
        d.read
      end
      self.layouts = LayoutReader.new(self).read
      Bridgetown::Hooks.trigger :site, :post_read, self

      yield(self) if block_given? # provide additional setup hook
      generate

      model = Bridgetown::Model::Base.find(origin_id)
      resource = model.as_resource_in_collection
      resource.transform!

      self.fast_render_mode = false

      resource.content
    end

    # Check that the destination dir isn't the source dir or a directory
    # parent to the source dir.
    def ensure_not_in_dest
      dest_pathname = Pathname.new(dest)
      Pathname.new(source).ascend do |path|
        if path == dest_pathname
          raise Errors::FatalException,
                "Destination directory cannot be or contain the Source directory."
        end
      end
    end

    def inspect
      "#<Bridgetown::Site #{metadata.inspect.delete_prefix("{").delete_suffix("}")}>"
    end
  end
end
