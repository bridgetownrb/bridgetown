# frozen_string_literal: true

module Bridgetown::Foundation
  module CoreExt
    module String
      module Colorize
        def self.included(klass)
          Bridgetown::Foundation::Ansi::COLORS.each_key do |color|
            klass.define_method color do |*args|
              Bridgetown::Foundation::Ansi.public_send(color, self, *args)
            end
          end
        end

        def reset_ansi
          Bridgetown::Foundation::Ansi.reset(self)
        end
      end

      module StartsWithAndEndsWith
        def self.included(klass)
          klass.alias_method :starts_with?, :start_with?
          klass.alias_method :ends_with?, :end_with?
        end
      end

      ::String.include Colorize, StartsWithAndEndsWith
    end
  end
end
