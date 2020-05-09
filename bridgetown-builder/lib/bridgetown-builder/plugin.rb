# frozen_string_literal: true

require "bridgetown-builder/dsl/generators"
require "bridgetown-builder/dsl/hooks"
require "bridgetown-builder/dsl/tags"
module Bridgetown
  module Builders
    class PluginBuilder
      include DSL::Generators
      include DSL::Hooks
      include DSL::Tags

      attr_accessor :functions, :name, :site, :config

      def initialize(name, current_site = nil)
        self.functions = Set.new
        self.name = name
        self.site = current_site || Bridgetown.sites.first

        self.config = if defined?(self.class::CONFIG_DEFAULTS)
                        Bridgetown::Utils.deep_merge_hashes(
                          self.class::CONFIG_DEFAULTS, site.config
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

      def get(url)
        body = connection.get(url).body
        data = JSON.parse(body, symbolize_names: true) rescue nil
        yield data || body
      end

      def connection
        Faraday.new(headers: { "Content-Type" => "application/json" })
      end
    end
  end
end
