# frozen_string_literal: true

module Bridgetown
  module Commands
    class Esbuild < Thor::Group
      include Thor::Actions
      extend Summarizable

      Registrations.register do
        register(Esbuild, "esbuild", "esbuild ACTION", Esbuild.summary)
      end

      def self.banner
        "bridgetown esbuild ACTION"
      end
      summary "Perform actions on the Bridgetown esbuild configuration"

      def self.exit_on_failure?
        true
      end

      def esbuild
        @logger = Bridgetown.logger
        return show_actions if args.empty?

        action = args.first
        if supported_actions.include?(action)
          perform action
        else
          @logger.error "Error:".red, "🚨 Please enter a valid action."
          say "\n"
          show_actions
        end
      end

      def self.source_root
        File.expand_path("./esbuild", __dir__)
      end

      def self.destination_root
        config.root_dir
      end

      protected

      def config
        @config ||= Bridgetown.configuration({ root_dir: Dir.pwd })
      end

      def package_json
        @package_json ||= begin
          package_json_file = File.read(Bridgetown.sanitized_path(config.root_dir, "package.json"))
          JSON.parse(package_json_file)
        end
      end

      def perform(action)
        automation = find_in_source_paths("#{action}.rb")
        inside(New.created_site_dir || Dir.pwd) do
          apply automation, verbose: false
        end
      end

      def show_actions
        say "Available actions:\n".bold

        longest_action = supported_actions.keys.max_by(&:size).size
        supported_actions.each do |action, description|
          say "#{action.ljust(longest_action).to_s.bold.blue}\t# #{description}"
        end
      end

      def supported_actions
        {
          setup: "Sets up an esbuild integration with Bridgetown in your project",
          update: "Updates the Bridgetown esbuild defaults to the latest available version",
          "migrate-from-webpack":
            "Removes Webpack from your project and installs/configures esbuild",
        }.with_indifferent_access
      end
    end
  end
end
