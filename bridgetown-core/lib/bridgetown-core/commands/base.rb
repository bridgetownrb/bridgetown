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
          case subcommand
          when "c"
            ["console"]
          when "s"
            ["start"]
          else
            super
          end
        end

        def display_rake_tasks(rake)
          rake.options.show_all_tasks = true
          rake.options.show_task_pattern = Regexp.new("")
          rake.options.show_tasks = :tasks
          rake.display_tasks_and_comments
        end

        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Style/GlobalVars
        def handle_no_command_error(cmd, _has_namespace = $thor_runner)
          require "rake"
          Rake::TaskManager.record_task_metadata = true

          Rake.with_application do |rake|
            rake.instance_variable_set(:@name, "bridgetown")
            rake.standard_exception_handling do
              rakefile, _location = rake.find_rakefile_location
              unless rakefile
                puts "No Rakefile found (searching: #{rake.class::DEFAULT_RAKEFILES.join(", ")})\n"
                new.invoke("help")
                return # rubocop:disable Lint/NonLocalExitFromIterator
              end
              rake.load_rakefile
              rake.top_level
            end
            cmd = cmd.split("[")
            args = []
            if cmd[1]
              args = cmd[1].gsub("\\,", "__COMMA__").delete_suffix!("]").split(",").map do |item|
                item.gsub("__COMMA__", ",")
              end
            end

            if Rake::Task.task_defined?(cmd[0])
              Rake::Task[cmd[0]].invoke(*args)
            else
              puts "Unknown task: #{cmd[0]}\n\nHere's a list of tasks you can run:"
              display_rake_tasks(rake)
            end
          end
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Style/GlobalVars

      desc "dream", "There's a place where that idea still exists as a reality"
      def dream
        puts ""
        puts "🎶 The Dream of the 90s is Alive in Portland... ✨"
        puts "          https://youtu.be/U4hShMEk1Ew"
        puts "          https://youtu.be/0_HGqPGp9iY"
        puts ""
      end

      desc "help <command>", "Show detailed command usage information and exit"
      def help(subcommand = nil) # rubocop:disable Metrics/MethodLength
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
          return if subcommand == "--version"

          super

          require "rake"
          Rake::TaskManager.record_task_metadata = true
          Rake.with_application do |rake|
            rake.instance_variable_set(:@name, "  bridgetown")
            rake.standard_exception_handling do
              rakefile, _location = rake.find_rakefile_location
              return unless rakefile # rubocop:disable Lint/NonLocalExitFromIterator

              rake.load_rakefile
              rake.top_level
              puts "Available Rake Tasks:"
              self.class.display_rake_tasks(rake)
            end
          end
        end
      end
    end
  end
end
