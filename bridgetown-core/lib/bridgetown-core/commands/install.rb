# frozen_string_literal: true

module Bridgetown
  module Commands
    class Install < Thor::Group
      include Thor::Actions
      extend Summarizable
      
      Registrations.register do
        register(Install, "install", "install ADD-IN", Install.summary)
      end
      
      def self.banner
        "bridgetown install ADD-IN"
      end
      summary "Install packaged Bridgetown add-ins"
      
      def self.exit_on_failure?
        true
      end
      
      def install_addin        
        addin_file = "#{addins_location}/#{args.first}.rb"

        if File.exist?(addin_file)
          invoke(Apply, [addin_file], options)
        else
          list_addins
        end
      end
      
      protected
      
      def list_addins
        say "Please specify a valid packaged addin from the below list:\n\n"
        addins.each do |addin|
          say addin
        end
      end
      
      def addins_location
        File.expand_path("../addins", __dir__)
      end
      
      def addins        
        Dir["#{addins_location}/*.rb"].map do |path|
          path.split("/").last.sub(".rb", "")
        end
      end
    end
  end
end
