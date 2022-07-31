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
    include SSR
    include Writable

    # @return [Bridgetown::Configuration]
    attr_reader :config

    # @return [Symbol]
    attr_reader :label

    # @return [Bridgetown::Utils::LoadersManager]
    attr_reader :loaders_manager

    attr_reader :cache_dir, :liquid_renderer

    # All files not pages/documents or structured data in the source folder
    # @return [Array<StaticFile>]
    attr_accessor :static_files

    # @return [Array<Layout>]
    attr_accessor :layouts

    # @return [Array<GeneratedPage>]
    attr_accessor :generated_pages

    attr_accessor :permalink_style, :time, :data,
                  :file_read_opts, :plugin_manager, :converters,
                  :generators, :reader

    # Initialize a new Site.
    #
    # @param config [Bridgetown::Configuration]
    # @param loaders_manager [Bridgetown::Utils::LoadersManager] initialized if none provided
    def initialize(config, label: :main, loaders_manager: nil)
      @label = label.to_sym
      self.config = config
      locale

      loaders_manager = if loaders_manager
                          loaders_manager.config = self.config
                          loaders_manager
                        else
                          Bridgetown::Utils::LoadersManager.new(self.config)
                        end
      @loaders_manager = loaders_manager

      @plugin_manager  = PluginManager.new(self)
      @cleaner         = Cleaner.new(self)
      @reader          = Reader.new(self)
      @liquid_renderer = LiquidRenderer.new(self)

      Bridgetown::Cache.base_cache["site_tmp"] = {}.with_dot_access
      ensure_not_in_dest

      Bridgetown::Current.sites[@label] = self
      Bridgetown::Hooks.trigger :site, :after_init, self

      reset   # Processable
      setup   # Extensible
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

    def tmp_cache
      Bridgetown::Cache.base_cache["site_tmp"]
    end

    def inspect
      "#<Bridgetown::Site #{metadata.inspect.delete_prefix("{").delete_suffix("}")}>"
    end
  end
end
