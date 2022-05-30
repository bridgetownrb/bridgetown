# frozen_string_literal: true

class Bridgetown::Site
  module Localizable
    # Returns the current and/or default configured locale
    # @return String
    def locale
      @locale ||= begin
        locale = ENV.fetch("BRIDGETOWN_LOCALE", config[:default_locale]).to_sym
        Dir["#{in_source_dir("_locales")}/*.{json,rb,yml}"].each do |locale_path|
          I18n.load_path << locale_path
        end
        I18n.available_locales = config[:available_locales]
        I18n.default_locale = locale
        I18n.fallbacks = (config[:available_locales] + [:en]).uniq.to_h do |available_locale|
          [available_locale, [available_locale, locale, :en].uniq]
        end
        locale
      end
    end

    # Sets the current locale for the site
    # @param new_locale [String] for example: "en" for English, "es" for Spanish
    def locale=(new_locale)
      I18n.locale = @locale = new_locale.to_sym
    end
  end
end
