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
    class Start < Thor::Group
      extend BuildOptions
      extend Summarizable
      include ConfigurationOverridable
      include Bridgetown::Utils::PidTracker

      Registrations.register do
        register(Start, "start", "start", Start.summary)
        register(Start, "dev", "dev", "Alias of start")
      end

      class_option :port,
                   aliases: "-P",
                   type: :numeric,
                   default: 4000,
                   desc: "Serve your site on the specified port. Defaults to 4000."
      class_option :bind,
                   aliases: "-B",
                   type: :string,
                   default: "0.0.0.0",
                   desc: "URL for the server to bind to."
      class_option :skip_frontend,
                   type: :boolean,
                   desc: "Don't load the frontend bundler (always true for production)."
      class_option :skip_live_reload,
                   type: :boolean,
                   desc: "Don't use the live reload functionality (always true for production)."

      def self.banner
        "bridgetown start [options]"
      end
      summary "Start the web server, frontend bundler, and Bridgetown watcher"

      def start # rubocop:todo Metrics/PerceivedComplexity
        Bridgetown.logger.writer.enable_prefix
        Bridgetown::Commands::Build.print_startup_message
        sleep 0.25

        options = Thor::CoreExt::HashWithIndifferentAccess.new(self.options)
        options[:start_command] = true

        # Load Bridgetown configuration into thread memory
        bt_options = configuration_with_overrides(options)

        # Set a local site URL in the config if one is not available
        if Bridgetown.env.development? && !options["url"]
          port = ENV["BRIDGETOWN_PORT"] || bt_options.port
          bt_options.url = "http://#{bt_options.bind}:#{port}"
        end

        server_uri = URI(bt_options.url)
        Bridgetown::Server.new({
          Host: server_uri.host,
          Port: server_uri.port,
          config: "config.ru",
        }).tap do |server|
          if server.serveable?
            create_pid_dir

            bt_options.skip_live_reload = !server.using_puma?

            build_args = ["-w"] + ARGV.reject { |arg| arg == "start" }
            build_pid = Process.fork { Bridgetown::Commands::Build.start(build_args) }
            add_pid(build_pid, file: :bridgetown)

            after_stop_callback = -> {
              say "Stopping Bridgetown server..."
              Bridgetown::Hooks.trigger :site, :server_shutdown
              Process.kill "SIGINT", build_pid
              remove_pidfile :bridgetown

              # Shut down the frontend bundler etc. if they're running
              unless Bridgetown.env.production? || bt_options[:skip_frontend]
                Bridgetown::Utils::Aux.kill_processes
              end
            }

            Bridgetown.logger.info ""
            Bridgetown.logger.info "Booting #{server.name} at:", server_uri.to_s.magenta
            Bridgetown.logger.info ""

            server.start(after_stop_callback)
          else
            say "Unable to find a Rack server."
          end
        end
      end
    end
  end
end
