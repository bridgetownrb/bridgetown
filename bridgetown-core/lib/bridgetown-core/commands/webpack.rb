# frozen_string_literal: true

module Bridgetown
  module Commands
    class Webpack < Thor::Group
      include Thor::Actions
      include ConfigurationOverridable
      extend Summarizable

      Registrations.register do
        register(Webpack, "webpack", "webpack ACTION", Webpack.summary)
      end

      def self.banner
        "bridgetown webpack ACTION"
      end
      summary "Perform actions on the bridgetown webpack configuration"

      def self.exit_on_failure?
        true
      end

      def webpack
        logger = Bridgetown.logger
        return show_actions if args.empty?

        action = args.first
        if supported_actions.include?(action)
          perform action
        else
          logger.error "Error:".red, "🚨 Please enter a valid action."
          say "\n"
          show_actions
        end
      end

      def self.source_root
        File.expand_path("./webpack", __dir__)
      end

      def self.destination_root
        site.root_dir
      end

      def site
        @site ||= Bridgetown::Site.new(configuration_with_overrides(quiet: true))
      end

      protected

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
          say action.ljust(longest_action).to_s.bold.blue + "\t" + "# #{description}"
        end
      end

      def supported_actions
        {
          setup: "Sets up a webpack integration with Bridgetown in your project",
          update: "Updates the Bridgetown webpack defaults to the latest available version",
          "enable-postcss": "Configures PostCSS in your project",
        }.with_indifferent_access
      end
    end
  end
end
