# frozen_string_literal: true

module Bridgetown
  module Commands
    module ConfigurationOverridable
      def self.included(klass)
        desc = "The environment used for this command (aka development, test, production, etc.)"
        klass.class_option :environment,
                           aliases: "-e",
                           desc: desc
      end

      # Create a full Bridgetown configuration with the options passed in as overrides
      #
      # @param options [Hash] the configuration overrides
      # @return [Bridgetown::Configuration] a full Bridgetown configuration
      def configuration_with_overrides(options)
        return options if options.is_a?(Bridgetown::Configuration)

        Bridgetown.configuration(options).tap do |new_config|
          Bridgetown::Current.preloaded_configuration = new_config
        end
      end
    end
  end
end
