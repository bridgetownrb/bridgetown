# frozen_string_literal: true

module Bridgetown
  # Superclass for a website's SiteBuilder abstract class
  class Builder < Bridgetown::Builders::PluginBuilder
    extend ActiveSupport::DescendantsTracker
    include ActiveSupport::Callbacks

    define_callbacks :build

    class << self
      def register
        Bridgetown::Builders::PluginBuilder.plugin_registrations << self
      end

      def before_build(...)
        set_callback(:build, :before, ...)
      end

      def after_build(...)
        set_callback(:build, :after, ...)
      end

      def around_build(...)
        set_callback(:build, :around, ...)
      end
    end

    def build_with_callbacks
      run_callbacks(:build) { build }
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
