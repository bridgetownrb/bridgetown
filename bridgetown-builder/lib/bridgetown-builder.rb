# frozen_string_literal: true

require "bridgetown-core"
require "bridgetown-core/version"

module Bridgetown
  module Builders
    autoload :PluginBuilder, "bridgetown-builder/plugin"
    autoload :DocumentBuilder, "bridgetown-builder/document"
    autoload :DocumentsGenerator, "bridgetown-builder/virtual_generator"
  end

  autoload :Builder, "bridgetown-builder/builder"
end

Bridgetown::Hooks.register_one :site, :pre_read, priority: :low, reloadable: false do |site|
  # SiteBuilder is the superclass sites can subclass to create any number of
  # builders, but if the site hasn't defined it explicitly, this is a no-op
  if defined?(SiteBuilder)
    SiteBuilder.descendants.map do |c|
      c.new(c.name, site)
    end
  end

  # If the documents generator is in use, we need to add it at the top of the
  # list so the site runs the generator before any others
  if Bridgetown::Builders.autoload?(:DocumentsGenerator).nil? && !site.generators.first.is_a?(Bridgetown::Builders::DocumentsGenerator)
      site.generators.unshift Bridgetown::Builders::DocumentsGenerator.new(site.config)
    end
  end
end

Bridgetown::Hooks.register_one :site, :pre_reload, reloadable: false do |site|
  # Remove all anonymous generator classes so they can later get reloaded
  site.converters.delete_if { |generator| generator.class.name.nil? }
  site.generators.delete_if { |generator| generator.class.name.nil? }

  unless Bridgetown::Builders.autoload? :DocumentsGenerator
    Bridgetown::Builders::DocumentsGenerator.clear_documents_to_generate
  end
end
