# frozen_string_literal: true

module Bridgetown::Foundation
  module RefineExt
    module String
      # Support string convenience methods for Dry::Inflector methods
      def self.string_inflector
        # Always use the current configured site inflector, if available
        if defined?(Bridgetown::Current) &&
            Bridgetown::Current.preloaded_configuration.is_a?(Bridgetown::Configuration)
          return Bridgetown::Current.preloaded_configuration.inflector
        end

        @string_inflector ||= Bridgetown::Foundation::Inflector.new
      end

      refine ::String do
        def camelize_upper = RefineExt::String.string_inflector.camelize(self)
        alias_method :camelize, :camelize_upper

        def camelize_lower = RefineExt::String.string_inflector.camelize_lower(self)
        def classify = RefineExt::String.string_inflector.classify(self)
        def constantize = RefineExt::String.string_inflector.constantize(self)
        def dasherize = RefineExt::String.string_inflector.dasherize(self)
        def humanize = RefineExt::String.string_inflector.humanize(self)
        def pluralize = RefineExt::String.string_inflector.pluralize(self)
        def singularize = RefineExt::String.string_inflector.singularize(self)
        def underscore = RefineExt::String.string_inflector.underscore(self)

        # Indent the string by n spaces
        def indent!(indent_by, *args)
          if args.length.positive?
            Kernel.warn "multiple arguments aren't supported by `indent!' in Bridgetown", uplevel: 1
          end

          # this seems odd, but gsub! can return nil if there's not a match, so
          # instead we'll return the string unchanged rather than cause a
          # nil bug
          gsub!(%r!^(?\!$)!, " " * indent_by) || self
        end

        # Return a duplicated string indented by n spaces
        def indent(indent_by, *args)
          if args.length.positive?
            Kernel.warn "multiple arguments aren't supported by `indent' in Bridgetown", uplevel: 1
          end

          dup.indent!(indent_by)
        end

        def questionable = Bridgetown::Foundation::QuestionableString.new(self)

        def inquiry = Bridgetown::Foundation.deprecation_warning(
          self, :inquiry, :questionable, 2026, 12
        ).then { questionable }
      end
    end
  end
end

module Bridgetown
  module Refinements
    include Foundation::RefineExt::String
  end
end
