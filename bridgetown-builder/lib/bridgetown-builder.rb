# frozen_string_literal: true

require "active_support/core_ext/hash/indifferent_access"

require "bridgetown-core"
require "bridgetown-core/version"

module Bridgetown
  module Builders
  end
end

require "bridgetown-builder/plugin"
require "bridgetown-builder/document"
require "bridgetown-builder/virtual_generator"

module Bridgetown
  # Superclass for a website's SiteBuilder abstract class
  class Builder < Bridgetown::Builders::PluginBuilder
    def initialize(name, _site = nil)
      super(name, _site)
      build
    end

    def build
      # subclass
    end

    def inspect
      name
    end

    def self.inherited(const)
      (@children ||= Set.new).add const
      catch_inheritance(const) do |const_|
        catch_inheritance(const_)
      end
    end

    def self.catch_inheritance(const)
      const.define_singleton_method :inherited do |const_|
        (@children ||= Set.new).add const_
        yield const_ if block_given?
      end
    end

    def self.descendants
      @children ||= Set.new
      out = @children.map(&:descendants)
      out << self unless name == "SiteBuilder"
      Set.new(out).flatten
    end
  end
end

Bridgetown::Hooks.register_one :site, :after_reset, reloadable: false do |site|
  if defined?(SiteBuilder)
    SiteBuilder.descendants.map do |c|
      c.new(c.name, site)
    end
  end
end

Bridgetown::Hooks.register_one :site, :before_reload, reloadable: false do |site|
  # remove all anonymous generator classes
  site.converters.delete_if { |generator| generator.class.name.nil? }
  site.generators.delete_if { |generator| generator.class.name.nil? }
  Bridgetown::Builders::VirtualGenerator.clear_documents_to_generate
end
