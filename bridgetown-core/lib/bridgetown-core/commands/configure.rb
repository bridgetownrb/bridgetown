# frozen_string_literal: true

module Bridgetown
  module Commands
    class Configure < Thor::Group
      include Thor::Actions
      extend Summarizable

      Registrations.register do
        register(Configure, "configure", "configure CONFIGURATION", Configure.summary)
      end

      def self.banner
        "bridgetown configure CONFIGURATION(S)"
      end
      summary "Set up bundled Bridgetown configurations"

      def self.exit_on_failure?
        true
      end

      def perform_configurations
        logger = Bridgetown.logger
        list_configurations if args.empty?

        args.each do |configuration|
          configure configuration
        rescue Thor::Error
          if New.created_site_dir || args.count > 1
            logger.error "Error:".red, "🚨 Configuration doesn't exist: #{configuration}"
          else
            list_configurations
          end
        end
      end

      def self.source_root
        File.expand_path("../configurations", __dir__)
      end

      protected

      def configure(configuration)
        configuration_file = find_in_source_paths("#{configuration}.rb")

        inside(New.created_site_dir || Dir.pwd) do
          Apply.new.invoke(:apply_automation, [configuration_file])
        end
      end

      def list_configurations
        say "Please specify a valid packaged configuration from the below list:\n\n"
        configurations.each do |configuration|
          configuration = set_color configuration, :blue, :bold
          say configuration
        end
      end

      def configurations
        inside self.class.source_root do
          return Dir.glob("*.rb").map { |file| file.sub(".rb", "") }
        end
      end
    end
  end
end
