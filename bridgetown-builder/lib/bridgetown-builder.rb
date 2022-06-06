# frozen_string_literal: true

require "bridgetown-core"
require "bridgetown-core/version"

module Bridgetown
  module Builders
    autoload :PluginBuilder, "bridgetown-builder/plugin"
  end

  autoload :Builder, "bridgetown-builder/builder"
end

Bridgetown::Hooks.register_one :site, :pre_read, priority: :low, reloadable: false do |site|
  builders = Bridgetown::Builders::PluginBuilder.plugin_registrations.to_a

  # SiteBuilder is the superclass sites can subclass to create any number of
  # builders, but if the site hasn't defined it explicitly, this is a no-op
  builders += SiteBuilder.descendants if defined?(SiteBuilder)

  builders.sort.map do |c|
    c.new(c.name, site).build_with_callbacks
  end
end

Bridgetown::Hooks.register_one :site, :pre_reload, reloadable: false do |site|
  # Remove all anonymous generator classes so they can later get reloaded
  site.converters.delete_if { |generator| generator.class.name.nil? }
  site.generators.delete_if { |generator| generator.class.name.nil? }
end
