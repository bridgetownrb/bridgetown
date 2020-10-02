# frozen_string_literal: true

require "bridgetown-builder/dsl/generators"
require "bridgetown-builder/dsl/helpers"
require "bridgetown-builder/dsl/hooks"
require "bridgetown-builder/dsl/http"
require "bridgetown-builder/dsl/liquid"
module Bridgetown
  module Builders
    class PluginBuilder
      include DSL::Generators
      include DSL::Helpers
      include DSL::Hooks
      include DSL::HTTP
      include DSL::Liquid

      attr_accessor :functions, :name, :site, :config

      def initialize(name, current_site = nil)
        self.functions = Set.new
        self.name = name
        self.site = current_site || Bridgetown.sites.first

        self.config = if defined?(self.class::CONFIG_DEFAULTS)
                        Bridgetown::Utils.deep_merge_hashes(
                          self.class::CONFIG_DEFAULTS.with_dot_access, site.config
                        )
                      else
                        site.config
                      end
      end

      def inspect
        "#{name} (Hook)"
      end

      def doc(path, &block)
        DocumentsGenerator.add(path, block)
      end
    end
  end
end
