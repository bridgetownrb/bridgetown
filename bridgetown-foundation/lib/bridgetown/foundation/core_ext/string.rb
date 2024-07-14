# frozen_string_literal: true

module Bridgetown::Foundation
  module CoreExt
    module String
      module Colorize
        class << self
          extend Inclusive::Class

          # @return [Bridgetown::Foundation::Packages::Ansi]
          public_packages def ansi = [Bridgetown::Foundation::Packages::Ansi]

          def included(klass)
            ansi.tap do |a|
              a.colors.each_key do |color|
                klass.define_method(color) { |*args| a.public_send(color, self, *args) }
              end
            end
          end
        end

        # Reset output colors back to a regular string output
        def reset_ansi
          Colorize.ansi.reset(self)
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
