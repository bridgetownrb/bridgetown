# frozen_string_literal: true

require "active_support/core_ext/hash/indifferent_access"

require "bridgetown-core"
require "bridgetown-core/version"

module Bridgetown
  module Builders
    autoload :PluginBuilder, "bridgetown-builder/plugin"
    autoload :DocumentBuilder, "bridgetown-builder/document"
    autoload :VirtualGenerator, "bridgetown-builder/virtual_generator"
  end

  autoload :Builder, "bridgetown-builder/builder"
end

Bridgetown::Hooks.register_one :site, :after_reset, reloadable: false do |site|
  if defined?(SiteBuilder)
    unless site.generators.first.is_a?(Bridgetown::Builders::VirtualGenerator)
      # Fire up the virtual generator on first load
      site.generators.unshift Bridgetown::Builders::VirtualGenerator.new(site.config)
    end

    SiteBuilder.descendants.map do |c|
      p "Instantiating decendants! #{c.name}"
      c.new(c.name, site)
    end
  end
end

Bridgetown::Hooks.register_one :site, :before_reload, reloadable: false do |site|
  # remove all anonymous generator classes
  site.converters.delete_if { |generator| generator.class.name.nil? }
  site.generators.delete_if { |generator| generator.class.name.nil? }
  unless Bridgetown::Builders.autoload? :VirtualGenerator
    Bridgetown::Builders::VirtualGenerator.clear_documents_to_generate
  end
end
