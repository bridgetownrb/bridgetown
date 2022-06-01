# frozen_string_literal: true

module Bridgetown
  module Commands
    class Configure < Thor::Group
      include Thor::Actions
      include Actions
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
        @logger = Bridgetown.logger
        list_configurations if args.empty?

        args.each do |configuration|
          configure configuration
        rescue Thor::Error
          @logger.error "Error:".red, "🚨 Configuration doesn't exist: #{configuration}"
        end
      end

      def self.source_root
        File.expand_path("../configurations", __dir__)
      end

      protected

      def configure(configuration)
        configuration_file = find_in_source_paths("#{configuration}.rb")

        inside(New.created_site_dir || Dir.pwd) do
          @templates_dir = File.expand_path("../configurations/#{configuration}", __dir__)
          apply configuration_file, verbose: false
        end
      end

      def list_configurations
        say "Please specify a valid packaged configuration from the below list:\n\n"
        configurations.each do |configuration|
          configuration = set_color configuration, :blue, :bold
          say configuration
        end
        say "\n"

        docs_url = "https://www.bridgetownrb.com/docs/bundled-configurations".yellow.bold
        say "For more info, check out the docs at: #{docs_url}"
      end

      def configurations
        inside self.class.source_root do
          return Dir.glob("*.rb").map { |file| file.sub(".rb", "") }.sort
        end
      end

      def in_templates_dir(*paths)
        paths.reduce(@templates_dir) do |base, path|
          Bridgetown.sanitized_path(base, path.to_s)
        end
      end
    end
  end
end
