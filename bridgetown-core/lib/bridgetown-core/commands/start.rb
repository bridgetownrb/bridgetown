# frozen_string_literal: true

module Bridgetown
  module Commands
    class Start < Bridgetown::Command
      module StartOptions
        def self.include_options(klass)
          klass.option "-P/--port <NUM>",
                       "Serve your site on the specified port. Defaults to 4000",
                       type: Integer
          klass.option "-B/--bind <IP>", "IP address for the server to bind to"
          klass.option "--skip-frontend",
                       "Don't load the frontend bundler (always true for production)"
          klass.option "--skip-live-reload",
                       "Don't use the live reload functionality (always true for production)"
        end
      end

      include ConfigurationOverridable
      include Freyia::Setup
      include Inclusive

      self.description = "Start the web server, frontend bundler, and Bridgetown watcher"

      options do
        BuildOptions.include_options(self)
        StartOptions.include_options(self)

        option "-P/--port <NUM>",
               "Serve your site on the specified port. Defaults to 4000",
               type: Integer
        option "-B/--bind <IP>", "IP address for the server to bind to"
        option "--skip-frontend", "Don't load the frontend bundler (always true for production)"
        option "--skip-live-reload",
               "Don't use the live reload functionality (always true for production)"
      end

      def call
        options = HashWithDotAccess::Hash.new(self.options)
        config = configuration_with_overrides(options)
        load_env(config)

        config.run_initializers! context: :static
        site = Bridgetown::Site.new(config)
        site.build

        container = Bridgetown::Container.new
        container.add_routine(Routines::Server.new(site: site, port: options[:port],
                                                   bind: options[:bind]))
        container.add_routine(Routines::SiteWatcher.new(site: site))
        container.add_routine(Routines::FrontendWatcher.new(site: site))

        begin
          container.run
          container.wait
        rescue Interrupt # rubocop:disable Lint/SuppressedException
        end
      end

      protected

      def load_env(config)
        initializer_file = File.join(config.root_dir, "config", "initializers.rb")
        if File.exist?(initializer_file) &&
            File.read(initializer_file) =~ %r!^\s*init\s*:dotenv!
          require "dotenv"
          Bridgetown.load_dotenv(root: config.root_dir)
        end
      end
    end

    Dev = Start.dup
    Dev.description = "Alias for the start command"

    register_command :start, Start
    register_command :dev, Dev
  end
end
