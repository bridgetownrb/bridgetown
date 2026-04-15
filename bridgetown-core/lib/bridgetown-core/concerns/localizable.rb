# frozen_string_literal: true

module Bridgetown
  module Localizable
    def all_locales
      return @all_locales if @all_locales

      @all_locales = site.locale_index&.[](locale_index_key) || find_matching_locales
    end

    def matches_resource?(item)
      if item.relative_path.is_a?(String)
        item.localeless_path == localeless_path
      else
        item.relative_path.parent == relative_path.parent
      end && item.data.slug == data.slug
    end

    def localeless_path
      relative_path.gsub(%r{\A#{data.locale}/}, "")
    end

    # Key used to group locale variants of the same content in the locale index.
    # Uses the same matching criteria as matches_resource? (slug + path identity).
    def locale_index_key
      slug = data.slug
      return unless slug

      path_key = if relative_path.is_a?(String)
                   localeless_path
                 else
                   relative_path.parent.to_s
                 end

      prefix = case self
               when Bridgetown::Resource::Base
                 collection.label
               when Bridgetown::GeneratedPage
                 "generated"
               end

      "#{prefix}:#{slug}:#{path_key}" if prefix
    end

    private

    def find_matching_locales
      result_set = case self
                   when Bridgetown::Resource::Base
                     collection.resources
                   when Bridgetown::GeneratedPage
                     site.generated_pages
                   else
                     []
                   end

      result_set.select { |item| matches_resource?(item) }.sort_by do |item|
        site.config.available_locales.index(item.data.locale) || Float::INFINITY
      end
    end
  end
end
