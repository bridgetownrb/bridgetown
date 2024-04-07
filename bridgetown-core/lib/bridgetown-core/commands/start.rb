# frozen_string_literal: true

require "rackup/server"

module Bridgetown
  class Server < Rackup::Server
    def start(after_stop_callback = nil)
      trap(:INT) { exit }
      super()
    ensure
      after_stop_callback.call if after_stop_callback
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

      class_option :bind, aliases: "-B", desc: "URI for Puma to bind to (start with tcp://)"
      class_option :skip_frontend,
                   type: :boolean,
                   desc: "Don't load the frontend bundler (always true for production)"
      class_option :skip_live_reload,
                   type: :boolean,
                   desc: "Don't use the live reload functionality (always true for production)"

      def self.banner
        "bridgetown start [options]"
      end
      summary "Start the Puma server, frontend bundler, and Bridgetown watcher"

      def start # rubocop:todo Metrics/PerceivedComplexity
        Bridgetown.logger.writer.enable_prefix
        Bridgetown::Commands::Build.print_startup_message
        sleep 0.25


        options = Thor::CoreExt::HashWithIndifferentAccess.new(self.options)
        options[:using_puma] = true

        # Load Bridgetown configuration into thread memory
        bt_options = configuration_with_overrides(options)

        # Set a local site URL in the config if one is not available
        if Bridgetown.env.development? && !options["url"]
          scheme = bt_options.bind&.split("://")&.first == "ssl" ? "https" : "http"
          port = bt_options.bind&.split(":")&.last || ENV["BRIDGETOWN_PORT"] || 4000
          bt_options.url = "#{scheme}://localhost:#{port}"
        end

        Bridgetown::Server.new({
          Host: "localhost",
          Port: 4000,
          config: "config.ru"
        }).tap do |server|
          if server.serveable?
            create_pid_dir

            build_args = ["-w"] + ARGV.reject { |arg| arg == "start" }
            build_pid = Process.fork { Bridgetown::Commands::Build.start(build_args) }
            add_pid(build_pid, file: :bridgetown)

            after_stop_callback = -> {
              say "Stopping Bridgetown server..."
              Bridgetown::Hooks.trigger :site, :server_shutdown
              Process.kill "SIGINT", build_pid
              remove_pidfile :bridgetown

              # Shut down webpack, browsersync, etc. if they're running
              Bridgetown::Utils::Aux.kill_processes
            }

            server.start(after_stop_callback)
          else
            say "Unable to find a Rack server."
          end
        end
      end
    end
  end
end
