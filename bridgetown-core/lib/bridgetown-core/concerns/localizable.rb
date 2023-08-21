# frozen_string_literal: true

module Bridgetown
  module Localizable
    def all_locales
      result_set = case self
                   when Bridgetown::Resource::Base
                     collection.resources
                   when Bridgetown::GeneratedPage
                     site.generated_pages
                   else
                     []
                   end

      matching_resources = result_set.select do |item|
        matches_resource?(item)
      end

      matching_resources.sort_by do |item|
        site.config.available_locales.index item.data.locale
      end
    end

    def matches_resource?(item)
      if item.relative_path.is_a?(String)
        item.localeless_path == localeless_path
      else
        item.relative_path.parent == relative_path.parent
      end && item.data.slug == data.slug
    end

    def localeless_path
      relative_path.gsub(/\A#{data.locale}\//, "")
    end
  end
end
