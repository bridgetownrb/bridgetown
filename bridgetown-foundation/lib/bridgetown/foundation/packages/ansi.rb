# frozen_string_literal: true

module Bridgetown::Foundation
  module Packages
    module Ansi
      extend self

      ESCAPE = format("%c", 27)
      MATCH = %r!#{ESCAPE}\[(?:\d+)(?:;\d+)*(j|k|m|s|u|A|B|G)|\e\(B\e\[m!ix
      COLORS = {
        bold: 1,
        black: 30,
        red: 31,
        green: 32,
        yellow: 33,
        blue: 34,
        magenta: 35,
        cyan: 36,
        white: 37,
      }.freeze

      def colors = COLORS

      # Strip ANSI from the current string.  It also strips cursor stuff,
      # well some of it, and it also strips some other stuff that a lot of
      # the other ANSI strippers don't.
      def strip(str)
        str.gsub MATCH, ""
      end

      # Does the string include ANSI color codes?
      def has?(str)
        !!(str =~ MATCH)
      end

      # Reset the color back to the default color so that you do not leak any
      # colors when you move onto the next line. This is probably normally
      # used as part of a wrapper so that we don't leak colors.
      def reset(str = "")
        @ansi_reset ||= format("%c[0m", 27)
        "#{@ansi_reset}#{str}"
      end

      # SEE: `self::COLORS` for a list of methods.  They are mostly
      # standard base colors supported by pretty much any xterm-color, we do
      # not need more than the base colors so we do not include them.
      COLORS.each do |color, num|
        define_method color do |str|
          "#{format("%c", 27)}[#{num}m#{str}#{reset}"
        end
      end
    end
  end
end
