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
        "bridgetown configure CONFIGURATION"
      end
      summary "Set up packaged Bridgetown configurations"
      
      def self.exit_on_failure?
        true
      end
      
      def perform_configuration
        begin
          configuration_file = find_in_source_paths("#{args.first}.rb")
          invoke(Apply, [configuration_file], options)
        rescue Thor::Error
          list_configurations
        end
      end
      
      def self.source_root
        File.expand_path("../configurations", __dir__)
      end
      
      protected
      
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
