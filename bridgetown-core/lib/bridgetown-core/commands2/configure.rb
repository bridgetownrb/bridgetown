# frozen_string_literal: true

module Bridgetown
  module Commands2
    class Configure < Samovar::Command
      Registrations.register Configure, "configure"

      self.description = "Set up bundled Bridgetown configurations"

      many :configurations, "One or more configuration names, separated by spaces"

      def call
        unless configurations
          print_usage
          return
        end

        puts "CONFIG! #{configurations}"
      end
    end
  end
end
