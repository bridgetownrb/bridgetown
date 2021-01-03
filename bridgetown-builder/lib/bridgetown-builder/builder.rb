# frozen_string_literal: true

module Bridgetown
  # Superclass for a website's SiteBuilder abstract class
  class Builder < Bridgetown::Builders::PluginBuilder
    extend ActiveSupport::DescendantsTracker

    class << self
      def register
        Bridgetown::Hooks.register_one :site, :pre_read, reloadable: false do |site|
          new(name, site)
        end
      end
    end

    # Subclass is expected to implement #build
    def initialize(name, current_site = nil)
      super(name, current_site)
      build
    end

    def inspect
      name
    end

    def self.descendants
      super.reject { |klass| ["SiteBuilder"].include?(klass.name) }
    end
  end
end
