# frozen_string_literal: true

module Bridgetown
  class Site
    require_all "bridgetown-core/concerns/site"

    include Configurable
    include Content
    include Extensible
    include Processable
    include Renderable
    include Writable

    attr_reader   :root_dir, :source, :dest, :cache_dir, :config,
                  :regenerator, :liquid_renderer, :components_load_paths,
                  :includes_load_paths
    attr_accessor :layouts, :pages, :static_files,
                  :exclude, :include, :lsi, :highlighter, :permalink_style,
                  :time, :future, :unpublished, :limit_posts,
                  :keep_files, :baseurl, :data, :file_read_opts,
                  :plugin_manager, :converters, :generators, :reader

    # Public: Initialize a new Site.
    #
    # config - A Hash containing site configuration details.
    def initialize(config)
      self.config = config

      @plugin_manager  = PluginManager.new(self)
      @cleaner         = Cleaner.new(self)
      @reader          = Reader.new(self)
      @regenerator     = Regenerator.new(self)
      @liquid_renderer = LiquidRenderer.new(self)

      ensure_not_in_dest

      Bridgetown.sites << self
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
  end
end
