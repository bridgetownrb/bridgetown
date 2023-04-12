# frozen_string_literal: true

module Bridgetown
  module Commands
    class Start < Thor::Group
      extend BuildOptions
      extend Summarizable
      include ConfigurationOverridable

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

        begin
          require("puma/detect")
        rescue LoadError
          raise "** Puma server gem not found. Check your Gemfile and Bundler env? **"
        end

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

        puma_pid =
          Process.fork do
            require "puma/cli"

            Puma::Runner.class_eval do
              def output_header(mode)
                log "* Puma version: #{Puma::Const::PUMA_VERSION} (#{ruby_engine}) (\"#{Puma::Const::CODE_NAME}\")" # rubocop:disable Layout/LineLength
                if mode == "cluster"
                  log "* Cluster Master PID: #{Process.pid}"
                else
                  log "* PID: #{Process.pid}"
                end
              end
            end

            puma_args = []
            if bt_options[:bind]
              puma_args << "--bind"
              puma_args << bt_options[:bind]
            end

            cli = Puma::CLI.new puma_args
            cli.launcher.events.on_stopped do
              Bridgetown::Hooks.trigger :site, :server_shutdown
            end
            cli.run
          end

        begin
          Signal.trap("TERM") do
            Process.kill "SIGINT", puma_pid
            sleep 0.5 # let it breathe
            exit 0 # this runs the ensure block below
          end

          Process.setproctitle("bridgetown #{Bridgetown::VERSION} [#{File.basename(Dir.pwd)}]")

          build_args = ["-w"] + ARGV.reject { |arg| arg == "start" }
          Bridgetown::Commands::Build.start(build_args)
        rescue StandardError => e
          Process.kill "SIGINT", puma_pid
          sleep 0.5
          raise e
        ensure
          # Shut down webpack, browsersync, etc. if they're running
          Bridgetown::Utils::Aux.kill_processes
        end

        sleep 0.5 # finish cleaning up
      end
    end
  end
end
