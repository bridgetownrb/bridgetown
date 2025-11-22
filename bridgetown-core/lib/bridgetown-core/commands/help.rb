# frozen_string_literal: true

module Bridgetown
  module Commands
    class Help < Samovar::Command
      Registrations.register Help, "help"

      self.description = "Show detailed command usage information and exit"

      one :command, "The name of a Bridgetown command", required: true

      def call
        found_command = parent.class.table[:command].commands[command]

        found_command&.new(name: command)&.print_usage

        return if found_command

        puts "Unknown command: #{command}\n\n"
        parent.print_usage
      end
    end
  end
end
