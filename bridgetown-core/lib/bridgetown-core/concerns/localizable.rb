# frozen_string_literal: true

module Bridgetown
  module Localizable
    # Sort items by their locale's position in the configured available_locales list.
    # Items with unknown locales sort last.
    def self.sort_by_locale(items, available_locales)
      items.sort_by { |item| available_locales.index(item.data.locale) || Float::INFINITY }
    end

    def all_locales
      return @all_locales if @all_locales

      @all_locales = site.tmp_cache.dig(:locale_index, locale_index_key) || find_matching_locales
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

      path_key = relative_path.is_a?(String) ? localeless_path : relative_path.parent.to_s
      prefix   = respond_to?(:collection) ? collection.label : "generated"

      "#{prefix}:#{slug}:#{path_key}"
    end

    private

    def find_matching_locales
      result_set = respond_to?(:collection) ? collection.resources : site.generated_pages

      Bridgetown::Localizable.sort_by_locale(
        result_set.select { |item| matches_resource?(item) },
        site.config.available_locales
      )
    end
  end
end
