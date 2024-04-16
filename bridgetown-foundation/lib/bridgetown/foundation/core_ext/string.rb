# frozen_string_literal: true

module Bridgetown::Foundation
  module CoreExt
    module String
      module Indentation
        def indent!(indent_by, *args)
          if args.length.positive?
            Kernel.warn "multiple arguments aren't supported by `indent!' in Bridgetown", uplevel: 1
          end

          gsub! %r!^(?\!$)!, " " * indent_by
        end

        def indent(indent_by, *args)
          if args.length.positive?
            Kernel.warn "multiple arguments aren't supported by `indent' in Bridgetown", uplevel: 1
          end

          dup.indent!(indent_by)
        end
      end

      module Questionable
        def questionable = Bridgetown::Foundation::QuestionableString.new(self)
        alias_method :inquiry, :questionable
        gem_deprecate :inquiry, :questionable, 2024, 12
      end

      module StartsWithAndEndsWith
        def self.included(klass)
          klass.alias_method :starts_with?, :start_with?
          klass.alias_method :ends_with?, :end_with?
        end
      end

      ::String.include Indentation, Questionable, StartsWithAndEndsWith
    end
  end
end
