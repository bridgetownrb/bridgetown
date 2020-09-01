# frozen_string_literal: true

module Bridgetown
  module Site::Localizable
    def locale
      if @locale
        @locale
      else
        @locale = ENV.fetch("BRIDGETOWN_LOCALE", config[:default_locale]).to_sym
        I18n.load_path << Dir[in_source_dir("_locales") + "/*.yml"]
        I18n.available_locales = config[:available_locales]
        I18n.default_locale = @locale
      end
    end

    def locale=(new_locale)
      I18n.locale = @locale = new_locale.to_sym
    end
  end
end
