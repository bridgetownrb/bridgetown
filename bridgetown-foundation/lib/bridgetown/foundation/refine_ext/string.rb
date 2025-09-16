# frozen_string_literal: true

module Bridgetown::Foundation
  module RefineExt
    module String
      refine ::String do
        def indent!(indent_by, *args)
          if args.length.positive?
            Kernel.warn "multiple arguments aren't supported by `indent!' in Bridgetown", uplevel: 1
          end

          # this seems odd, but gsub! can return nil if there's not a match, so
          # instead we'll return the string unchanged rather than cause a
          # nil bug
          gsub!(%r!^(?\!$)!, " " * indent_by) || self
        end

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
