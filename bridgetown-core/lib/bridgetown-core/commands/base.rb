# frozen_string_literal: true

require_all "bridgetown-core/commands/concerns"
require_all "bridgetown-core/commands"

module Bridgetown
  module Commands
    class Base < Thor
      def self.exit_on_failure?
        true
      end

      Registrations.registrations.each do |block|
        instance_exec(&block)
      end

      class << self
        # Override single character commands if necessary
        def find_command_possibilities(subcommand)
          if subcommand == "c"
            ["console"]
          else
            super
          end
        end
      end

      desc "dream", "There's a place where that idea still exists as a reality"
      def dream
        puts ""
        puts "🎶 The Dream of the 90s is Alive in Portland... ✨"
        puts "          https://youtu.be/U4hShMEk1Ew"
        puts "          https://youtu.be/0_HGqPGp9iY"
        puts ""
      end

      desc "help <command>", "Show detailed command usage information and exit"
      def help(subcommand = nil)
        if subcommand && respond_to?(subcommand)
          klass = Kernel.const_get("Bridgetown::Commands::#{subcommand.capitalize}")
          klass.start(["-h"])
        else
          puts "Bridgetown v#{Bridgetown::VERSION.magenta} \"#{Bridgetown::CODE_NAME.yellow}\"" \
               " is a Webpack-aware, Ruby-powered static site generator for the modern Jamstack era"
          puts ""
          puts "Usage:"
          puts "  bridgetown <command> [options]"
          puts ""
          super
        end
      end
    end
  end
end
