# frozen_string_literal: true

require "bridgetown-builder/dsl/generators"
require "bridgetown-builder/dsl/helpers"
require "bridgetown-builder/dsl/hooks"
require "bridgetown-builder/dsl/inspectors"
require "bridgetown-builder/dsl/http"
require "bridgetown-builder/dsl/liquid"
require "bridgetown-builder/dsl/resources"

module Bridgetown
  module Builders
    class PluginBuilder
      include Bridgetown::Prioritizable

      self.priorities = {
        highest: 100,
        high: 10,
        normal: 0,
        low: -10,
        lowest: -100,
      }.freeze

      include DSL::Generators
      include DSL::Helpers
      include DSL::Hooks
      include DSL::Inspectors
      include DSL::HTTP
      include DSL::Liquid
      include DSL::Resources

      attr_accessor :functions, :name, :site, :config

      class << self
        def plugin_registrations
          @plugin_registrations ||= Set.new
        end
      end

      def initialize(name = nil, current_site = nil)
        self.functions = Set.new
        self.name = name || self.class.name
        self.site = current_site || Bridgetown::Current.site

        self.config = if defined?(self.class::CONFIG_DEFAULTS)
                        Deprecator.deprecation_message(
                          "Using `CONFIG_DEFAULTS' in your builder is deprecated. " \
                          "Switch to defining config data via an initializer instead."
                        )
                        Bridgetown::Utils.deep_merge_hashes(
                          self.class::CONFIG_DEFAULTS.with_dot_access, site.config
                        )
                      else
                        site.config
                      end
      end

      def doc(*)
        raise Bridgetown::Errors::FatalException,
              "The `doc' method has been removed. Please use the `new_resource' builder DSL instead"
      end
    end
  end
end
