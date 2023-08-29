# frozen_string_literal: true

module Bridgetown
  module Filters
    module LocalizationFilters
      def l(input, format = nil, locale = nil)
        date = Liquid::Utils.to_date(input)
        return input if date.nil?

        format = maybe_symbolized(format, date)
        locale ||= maybe_locale(format)
        format = nil if locale == format

        I18n.l(date, format: format, locale: locale)
      end

      private

      def maybe_locale(format)
        return if format.nil?

        Bridgetown::Current.site.config.available_locales.include?(format.to_sym) ? format : nil
      end

      def maybe_symbolized(format, object)
        return if format.nil?

        type = type_of(object)
        I18n.t("#{type}.formats").key?(format.to_sym) ? format.to_sym : format
      end

      def type_of(object)
        object.respond_to?(:sec) ? "time" : "date"
      end
    end
  end
end
