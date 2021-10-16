# frozen_string_literal: true

module Bridgetown
  # Superclass for a website's SiteBuilder abstract class
  class Builder < Bridgetown::Builders::PluginBuilder
    extend ActiveSupport::DescendantsTracker
    include ActiveSupport::Callbacks

    define_callbacks :build

    class << self
      def register
        Bridgetown::Hooks.register_one :site, :pre_read, reloadable: false do |site|
          new(name, site).build_with_callbacks
        end
      end

      ruby2_keywords def before_build(*args, &block)
        set_callback :build, :before, *args, &block
      end

      ruby2_keywords def after_build(*args, &block)
        set_callback :build, :after, *args, &block
      end

      ruby2_keywords def around_build(*args, &block)
        set_callback :build, :around, *args, &block
      end
    end

    def build_with_callbacks
      run_callbacks(:build) { build }
      self
    end

    def inspect
      name
    end

    def self.descendants
      site_builder_name = "SiteBuilder"
      super.reject { |klass| [site_builder_name].include?(klass.name) }
    end
  end
end
