# frozen_string_literal: true

require_relative "../commands/concerns/actions"

module Bridgetown
  module Commands2
    class Configure < Samovar::Command
      include Freyia::Setup
      include Commands::Actions

      Registrations.register Configure, "configure"

      self.description = "Set up bundled Bridgetown configurations"

      many :configurations, "One or more configuration names, separated by spaces"

      def self.source_root
        File.expand_path("../configurations", __dir__)
      end

      def call
        self.destination_root = Dir.pwd
        self.source_paths = [self.class.source_root]

        unless configurations
          print_usage
          list_configurations
          return
        end

        @logger = Bridgetown.logger

        configurations.each do |configuration|
          configure configuration
        rescue Thor::Error
          @logger.error "Error:".red, "🚨 Configuration doesn't exist: #{configuration}"
        end
      end

      protected

      def configure(configuration)
        configuration_file = find_in_source_paths("#{configuration}.rb")

        inside(Dir.pwd) do #New.created_site_dir || Dir.pwd) do
          @templates_dir = File.expand_path("../configurations/#{configuration}", __dir__)
          apply configuration_file, verbose: false
        end
      end

      def list_configurations
        say "Please specify a valid packaged configuration from the below list:\n\n"

        configuration_files.each do |configuration|
          configuration = set_color configuration, :blue, :bold
          say configuration
        end
        say "\n"

        docs_url = "https://www.bridgetownrb.com/docs/bundled-configurations".yellow.bold
        say "For more info, check out the docs at: #{docs_url}"
      end

      def configuration_files
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
