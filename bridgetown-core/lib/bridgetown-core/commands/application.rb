# frozen_string_literal: true

module Bridgetown
  module Commands
    # Register a new command for the Bridgetown CLI
    #
    # @param name [Symbol]
    # @param klass [Bridgetown::Command]
    def self.register_command(name, klass)
      Registrations.register(klass, name)
    end
  end
end

require_all "bridgetown-core/commands/concerns"
require_all "bridgetown-core/commands"

module Bridgetown
  module Commands
    class Application < Bridgetown::Command
      self.description =
        "next-generation, progressive site generator & fullstack framework, powered by Ruby"

      def self.registrations = @registrations ||= {}

      def self.register(klass, name, *)
        registrations[name.to_s] = klass
      end

      nested(:command, registrations)

      def self.desc(name, description)
        @next_cmd_name = name.split.first
        @next_cmd_description = description
      end

      def self.subcommand(name, klass)
        return unless @next_cmd_name == name

        table[:command].commands[name] = klass
        klass.description = @next_cmd_description

        @next_cmd_name = nil
        @next_cmd_description = nil
      end

      def parse(input)
        Registrations.load_registrations self.class
        self.class.table.merged.parse(input, self)

        return self if input.empty?

        new_input = locate_command(input)
        unless new_input
          locate_rake_task(input)
          return self
        end

        parse(new_input)
      end

      def call
        if @command
          @command.()
        else
          print_usage
        end
      end

      def print_usage # rubocop:disable Metrics
        puts "Bridgetown v#{Bridgetown::VERSION.magenta} \"#{Bridgetown::CODE_NAME.yellow}\" " \
             "is a #{self.class.description}"
        puts ""
        puts "Usage:".bold.green + " #{"bridgetown".bold.cyan} #{"<command> [options]".cyan}\n\n"
        puts "Commands:".bold.green

        commands = self.class.table[:command].commands.to_h do |name, command|
          inputs = command.table.each.find do |item|
            item.is_a?(Samovar::Many) || item.is_a?(Samovar::One) || item.is_a?(Samovar::Nested)
          end
          name = name.bold.cyan
          name = "#{name} #{"<#{inputs.key.upcase}>".cyan}" if inputs
          [name, command]
        end

        name_max_length = commands.keys.map { Foundation::Packages::Ansi.strip(_1).length }.max
        commands.find do |name, command|
          spaces = " " * (name_max_length - Foundation::Packages::Ansi.strip(name).length)
          puts "  #{"bridgetown".cyan} #{name}  #{spaces}#{command.description}"
        end

        puts ""

        require "rake"
        Rake::TaskManager.record_task_metadata = true
        Rake.with_application do |rake|
          rake.instance_variable_set(:@name, "  bridgetown")
          rake.standard_exception_handling do
            rakefile, _location = rake.find_rakefile_location
            return unless rakefile # rubocop:disable Lint/NonLocalExitFromIterator

            load_rake_tasks(rake)
            puts "Available Rake Tasks:".bold.green
            display_rake_tasks(rake, name_max_length)
          end
        end
      end

      # @param input [String]
      def locate_command(input)
        token = input.first

        case token
        when "--help", "-help", "-h"
          input[0] = "help"
          input
        when "c"
          input[0] = "console"
          input
        when "s"
          input[0] = "start"
          input
        else
          self.class.table[:command].commands.find do |name, _command|
            next unless name.start_with?(token)

            input[0] = name
            break input
          end
        end
      end

      # @param input [String]
      def locate_rake_task(input) # rubocop:todo Metrics
        require "rake"
        Rake::TaskManager.record_task_metadata = true
        cmd = input.first

        Rake.with_application do |rake|
          rake.standard_exception_handling do
            rakefile, _location = rake.find_rakefile_location
            unless rakefile
              puts "No Rakefile found (searching: #{rake.class::DEFAULT_RAKEFILES.join(", ")})\n\n"
              new.invoke("help")
              return # rubocop:disable Lint/NonLocalExitFromIterator
            end
            rake.init("bridgetown")
            load_rake_tasks(rake)
          end

          # either return a command proc or nothing, #call will handle either case
          if Rake::Task.task_defined?(cmd.split("[")[0])
            @command = -> { rake.top_level }
          else
            puts "#{"Unknown token:".bold.red} #{cmd.split("[")[0].yellow}\n\n"
          end
        rescue RuntimeError => e
          # re-raise error unless it's an error through Minitest
          raise e unless e.message.include?("ruby -Ilib:test")

          Bridgetown.logger.error "test aborted!"
          Bridgetown.logger.error e.message
          exit(false)
        end
      end

      # @param rake [Rake::Application]
      def display_rake_tasks(rake, previous_max_length)
        # based in part on `Rake::Application#display_tasks_and_comments`
        displayable_tasks = rake.tasks.to_h do |t|
          [t.name_with_args, t.comment]
        end

        name_max_length = [previous_max_length, displayable_tasks.keys.map(&:length).max].max
        displayable_tasks.find do |name, comment|
          next if name == "default"

          spaces = " " * (name_max_length - name.length)
          puts "  #{"bridgetown".cyan} #{name.bold.cyan}  #{spaces}#{comment}"
        end
      end

      # @param rake [Rake::Application]
      def load_rake_tasks(rake)
        rake.load_rakefile
        tasks = rake.instance_variable_get(:@tasks)
        rake.instance_variable_set(:@tasks, tasks.reject do |_k, v|
          v.locations.first&.include?("/lib/rails/tasks/") ||
            v.locations.first&.include?("/lib/rake/dsl_definition")
        end)
      end
    end

    class Dream < Bridgetown::Command
      self.description = "There's a place where that idea still exists as a reality"

      def call
        puts ""
        puts "🎶 The Dream of the 90s is Alive in Portland... ✨"
        puts "          https://youtu.be/U4hShMEk1Ew"
        puts "          https://youtu.be/0_HGqPGp9iY"
        puts ""
      end
    end

    register_command :dream, Dream
  end
end
