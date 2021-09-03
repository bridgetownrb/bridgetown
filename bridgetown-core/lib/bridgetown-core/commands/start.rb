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

      def start
        Bridgetown.logger.writer.enable_prefix
        Bridgetown::Commands::Build.print_startup_message
        sleep 0.25

        unless Bundler.definition.specs.find { |s| s.name == "puma" }
          raise "** No Rack-compatible server found **"
        end

        configuration_with_overrides(options) # load Bridgetown configuration into thread memory

        rackpid =
          Process.fork do
            require "puma/cli"

            puma_args = []
            if options[:bind]
              puma_args << "--bind"
              puma_args << options[:bind]
            end

            cli = Puma::CLI.new puma_args
            cli.run
          end

        begin
          unless Bridgetown.env.production? || options[:skip_frontend]
            require "rake"
            Rake.with_application do |rake|
              rake.load_rakefile
              rake["frontend:servers"].invoke(true, options[:skip_live_reload])
            end
          end

          build_args = ["-w"] + ARGV.reject { |arg| arg == "start" }
          if Bridgetown.environment == "development" && !options["url"]
            build_args << "--url"
            build_args << "http://localhost:4000"
          end
          Bridgetown::Commands::Build.start(build_args)
        rescue StandardError => e
          Process.kill "SIGINT", rackpid
          sleep 0.5
          raise e
        ensure
          Bridgetown::Utils::Aux.kill_processes
        end

        sleep 0.5 # finish cleaning up
      end
    end
  end
end
