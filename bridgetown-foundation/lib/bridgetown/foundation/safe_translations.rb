# frozen_string_literal: true

module Bridgetown
  module Foundation
    # NOTE: this is tested by `test/test_ruby_helpers.rb` in bridgetown-core
    #
    # This is loosely based on the HtmlSafeTranslation module from ActiveSupport, but you can
    # actually use it for any kind of safety use case in a translation setting because its
    # decoupled from any specific escaping or safety mechanisms.
    module SafeTranslations
      def self.translate(key, escaper, safety_method = :html_safe, **options)
        safe_options = escape_translation_options(options, escaper)

        i18n_error = false

        exception_handler = ->(*args) do
          i18n_error = true
          I18n.exception_handler.(*args)
        end

        I18n.translate(key, **safe_options, exception_handler:).then do |translation|
          i18n_error ? translation : safe_translation(translation, safety_method)
        end
      end

      def self.escape_translation_options(options, escaper)
        @reserved_i18n_keys ||= I18n::RESERVED_KEYS.to_set

        options.to_h do |name, value|
          unless @reserved_i18n_keys.include?(name) || (name == :count && value.is_a?(Numeric))
            next [name, escaper.(value)]
          end

          [name, value]
        end
      end

      def self.safe_translation(translation, safety_method)
        @safe_value ||= -> { _1.respond_to?(safety_method) ? _1.send(safety_method) : _1 }

        return translation.map { @safe_value.(_1) } if translation.respond_to?(:map)

        @safe_value.(translation)
      end
    end
  end
end
