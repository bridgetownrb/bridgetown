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

    def self.autoload_config_folder(root:)
      config_folder = File.join(root, "config")
      loader = Zeitwerk::Loader.new
      loader.push_dir config_folder
      loader.ignore(File.join(config_folder, "puma.rb"))
      loader.enable_reloading unless ENV["BRIDGETOWN_ENV"] == "production"
      loader.setup
      loader.eager_load

      unless ENV["BRIDGETOWN_ENV"] == "production"
        begin
          listener = Listen.to(config_folder) do |_modified, _added, _removed|
            loader.reload
            loader.eager_load
          end
          listener.start
        # interrupt isn't handled well by the listener
        rescue ThreadError # rubocop:disable Lint/SuppressedException
        end
      end
    rescue Zeitwerk::Error
      # We assume if there's an error it's becuase Zeitwerk already registered this folder,
      # so it's fine to swallow the error
    end

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
      self.class.autoload_config_folder(root: config.root_dir)
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
