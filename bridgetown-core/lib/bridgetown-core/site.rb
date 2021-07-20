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

    # NOTE: Eventually pages will be deprecated once the Resource content engine
    # is default
    alias_method :generated_pages, :pages

    attr_accessor :permalink_style, :time, :data,
                  :file_read_opts, :plugin_manager, :converters,
                  :generators, :reader

    # Initialize a new Site.
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
