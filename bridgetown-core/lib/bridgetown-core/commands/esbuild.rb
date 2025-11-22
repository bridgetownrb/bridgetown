# frozen_string_literal: true

module Bridgetown
  module Commands
    class Esbuild < Bridgetown::Command
      include Automations

      self.description = "Perform actions on the Bridgetown esbuild configuration"

      one :command, "setup, update, migrate-from-webpack"

      def self.exit_on_failure?
        true
      end

      def call(new_site_dir: nil)
        @logger = Bridgetown.logger
        return show_actions unless command

        self.source_paths = [File.expand_path("../commands/esbuild", __dir__)]
        self.destination_root = new_site_dir || config.root_dir

        if supported_actions.include?(command.to_sym)
          perform command
        else
          @logger.error "Error:".red, "🚨 Please enter a valid action."
          say "\n"
          show_actions
        end
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
        inside(destination_root) do
          apply automation, verbose: false
        end
      end

      def show_actions
        say "Available actions:\n".bold

        longest_action = supported_actions.keys.max_by(&:size).size
        supported_actions.each do |action, description|
          say "#{action.to_s.ljust(longest_action).bold.blue}\t# #{description}"
        end
      end

      def supported_actions
        {
          setup: "Sets up an esbuild integration with Bridgetown in your project",
          update: "Updates the Bridgetown esbuild defaults to the latest available version",
          "migrate-from-webpack":
            "Removes Webpack from your project and installs/configures esbuild",
        }
      end
    end

    register_command :esbuild, Esbuild
  end
end
