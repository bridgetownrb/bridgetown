# frozen_string_literal: true

module Bridgetown
  module Commands
    module ConfigurationOverridable
      def self.included(klass)
        desc = "The environment used for this command (aka development, test, production, etc.)"
        klass.class_option :environment,
                           aliases: "-e",
                           desc:
      end

      # Create a full Bridgetown configuration with the options passed in as overrides
      #
      # @param options [Hash] the configuration overrides
      # @param preloaded [Bridgetown::Configuration, Bridgetown::Configuration::Preflight]
      #   a preloaded config or preflight
      # @return [Bridgetown::Configuration] a full Bridgetown configuration
      def configuration_with_overrides(options, preloaded = nil)
        return preloaded.merge!(options) if preloaded.is_a?(Bridgetown::Configuration)

        Bridgetown.configuration(options)
      end
    end
  end
end
