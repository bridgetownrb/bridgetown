# frozen_string_literal: true

module Bridgetown
  module Filters
    module TranslationFilters
      def t(input, options = "")
        options = string_to_hash(options)
        locale = options.delete(:locale)
        count = options.delete(:count)
        options[:count] = count.to_i unless count.nil?

        I18n.t(input.to_s, locale: locale, **options)
      rescue ArgumentError
        input
      end

      private

      def string_to_hash(options)
        options.split(",").to_h { |e| e.split(":").map(&:strip) }.symbolize_keys
      end
    end
  end
end
