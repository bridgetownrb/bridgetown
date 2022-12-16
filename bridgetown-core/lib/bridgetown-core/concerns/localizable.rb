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
        item.relative_path.parent == relative_path.parent && item.data.slug == data.slug
      end

      matching_resources.sort_by do |item|
        site.config.available_locales.index item.data.locale
      end
    end
  end
end
