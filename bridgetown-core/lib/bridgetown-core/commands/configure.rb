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
        configuration_file = "#{configurations_location}/#{args.first}.rb"

        if File.exist?(configuration_file)
          invoke(Apply, [configuration_file], options)
        else
          list_configurations
        end
      end
      
      protected
      
      def list_configurations
        say "Please specify a valid packaged configuration from the below list:\n\n"
        configurations.each do |configuration|
          say configuration
        end
      end
      
      def configurations_location
        File.expand_path("../configurations", __dir__)
      end
      
      def configurations        
        Dir["#{configurations_location}/*.rb"].map do |path|
          path.split("/").last.sub(".rb", "")
        end
      end
    end
  end
end
