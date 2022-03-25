# frozen_string_literal: true

module Bridgetown
  module Localizable
    def in_locales
      case self
      when Bridgetown::Resource::Base
        collection.resources.select { |item| item.data.slug == data.slug }.sort_by do |item|
          site.config.available_locales.index item.data.locale
        end
      when Bridgetown::GeneratedPage
        site.generated_pages.select { |item| item.data.slug == data.slug }.sort_by do |item|
          site.config.available_locales.index item.data.locale
        end
      end
    end
  end
end
