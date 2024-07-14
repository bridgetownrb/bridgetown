# frozen_string_literal: true

module Bridgetown
  # Superclass for a website's SiteBuilder abstract class
  class Builder < Bridgetown::Builders::PluginBuilder
    class << self
      def register
        Bridgetown::Builders::PluginBuilder.plugin_registrations << self
      end

      def before_build(...)
        add_callback(:before, ...)
      end

      def after_build(...)
        add_callback(:after, ...)
      end

      def callbacks
        @callbacks ||= {}
      end

      def add_callback(name, method_name = nil, &block)
        callbacks[name] ||= []
        callbacks[name] << (block || proc { send(method_name) })
      end
    end

    def build_with_callbacks
      self.class.callbacks[:before]&.each { instance_exec(&_1) }
      build
      self.class.callbacks[:after]&.each { instance_exec(&_1) }
      self
    end

    def inspect
      "#<#{name}>"
    end

    def self.descendants
      site_builder_name = "SiteBuilder"
      super.reject { |klass| [site_builder_name].include?(klass.name) }
    end
  end
end
