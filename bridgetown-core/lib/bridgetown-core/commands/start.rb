# frozen_string_literal: true

require "rackup/server"

module Bridgetown
  class Server < Rackup::Server
    def start(after_stop_callback = nil)
      trap(:INT) { exit }
      super()
    ensure
      after_stop_callback&.call
    end

    def name
      server.to_s.split("::").last
    end

    def using_puma?
      name == "Puma"
    end

    def serveable?
      server
      true
    rescue LoadError, NameError
      false
    end
  end

  module Commands
    class Start < Bridgetown::Command
      include ConfigurationOverridable
      include Freyia::Setup
      include Inclusive

      self.description = "Start the web server, frontend bundler, and Bridgetown watcher"

      options do
        BuildOptions.include_options(self)
        option "-P/--port <NUM>",
               "Serve your site on the specified port. Defaults to 4000",
               type: Integer
        option "-B/--bind <IP>", "IP address for the server to bind to", default: "0.0.0.0"
        option "--skip-frontend", "Don't load the frontend bundler (always true for production)"
        option "--skip-live-reload",
               "Don't use the live reload functionality (always true for production)"
      end

      def call # rubocop:disable Metrics
        pid_tracker = packages[Bridgetown::Foundation::Packages::PidTracker]
        Bridgetown.logger.writer.enable_prefix
        Bridgetown::Commands::Build.print_startup_message
        sleep 0.25

        options = HashWithDotAccess::Hash.new(self.options)
        options[:start_command] = true

        # Load Bridgetown configuration into thread memory
        bt_options = configuration_with_overrides(options)
        bt_options.port = port = load_env_and_determine_port(bt_options, options)
        # TODO: support Puma serving HTTPS directly?
        bt_bound_url = "http://#{bt_options.bind}:#{port}"

        # Set a local site URL in the config if one is not available
        if Bridgetown.env.development? && !options["url"]
          bt_options.url = bt_bound_url.sub("0.0.0.0", "localhost")
        end

        Bridgetown::Server.new({
          Host: bt_options.bind,
          Port: port,
          config: rack_config_file,
        }).tap do |server|
          if server.serveable?
            pid_tracker.create_pid_dir

            bt_options.skip_live_reload ||= !server.using_puma?

            build_args = ["-w"] + Array(ARGV[1..])
            build_pid = Process.fork { Bridgetown::Commands::Build[*build_args].() }
            pid_tracker.add_pid(build_pid, file: :bridgetown)

            after_stop_callback = -> {
              say "Stopping Bridgetown server..."
              Bridgetown::Hooks.trigger :site, :server_shutdown
              Process.kill "SIGINT", build_pid
              pid_tracker.remove_pidfile :bridgetown

              # Shut down the frontend bundler etc. if they're running
              unless Bridgetown.env.production? || bt_options[:skip_frontend]
                Bridgetown::Utils::Aux.kill_processes
              end
            }

            Bridgetown.logger.info ""
            Bridgetown.logger.info "Booting #{server.name} at:", bt_bound_url.to_s.magenta
            Bridgetown.logger.info ""

            server.start(after_stop_callback)
          else
            say "Unable to find a Rack server."
          end
        end
      end

      protected

      def rack_config_file
        File.exist?("config.ru") ?
          "config.ru" :
          File.expand_path("../rack/default_config.ru", __dir__)
      end

      def load_env_and_determine_port(config, options)
        initializer_file = File.join(config.root_dir, "config", "initializers.rb")
        if File.exist?(initializer_file) &&
            File.read(initializer_file) =~ %r!^\s*init\s*:dotenv!
          require "dotenv"
          Bridgetown.load_dotenv(root: config.root_dir)
        end

        # Options ordering for "who wins" is:
        #   1. CLI
        #   2. BRIDGETOWN_PORT env var
        #   3. YAML config (if present)
        #   4. 4000
        options[:port] || ENV.fetch("BRIDGETOWN_PORT", config.port || 4000)
      end
    end

    Dev = Start.dup
    Dev.description = "Alias for the start command"

    register_command :start, Start
    register_command :dev, Dev
  end
end
