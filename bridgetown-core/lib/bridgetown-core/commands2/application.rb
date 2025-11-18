require "samovar"

require_all "bridgetown-core/commands2/concerns"
require "bridgetown-core/commands2/registrations"
require_all "bridgetown-core/commands2"

Samovar::Command.class_eval do
  def self.summary = description
end

module Bridgetown
  module Commands2
    class Application < Samovar::Command
      self.description = "next-generation, progressive site generator & fullstack framework, powered by Ruby"

      # options do
      #   option "--help", "Do you need help?"
      # end

      def self.registrations = @registrations ||= {}

      def self.register(klass, name, *)
        registrations[name] = klass
      end

      Registrations.load_registrations(self)

      nested(:command, registrations)

      # nested :command, {
      #   "console" => Console
      # }

      def call
        if @command
          @command.()
        else
          print_usage
        end
      end

      def print_usage
        puts "Bridgetown v#{Bridgetown::VERSION.magenta} \"#{Bridgetown::CODE_NAME.yellow}\" " \
             "is a #{self.class.description}"
        puts ""
        puts "Usage:"

        puts "  bridgetown <command> [options]"
        puts ""
        puts "Commands:"
        item = self.class.table[:command]

        commands = item.commands.to_h do |name, command|
          inputs = command.table.each.find { _1.is_a?(Samovar::Many) || _1.is_a?(Samovar::One) }
          name = "#{name} #{inputs.key.upcase}" if inputs

          [name, command]
        end

        name_max_length = commands.keys.map { _1.to_s.length }.max
        commands.find do |name, command|
          spaces = " " * (name_max_length - name.length)

          puts "  bridgetown #{name}  #{spaces}# #{command.description}"
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
            puts "Available Rake Tasks:"
            display_rake_tasks(rake)
          end
        end
      end

      def locate_token(token, input:)
        if ["--help", "-help", "-h"].include?(token)
          print_usage
          return
        end

        item = self.class.table[:command]

        completed = item.commands.find do |name, command|
          next unless name.start_with?(token)

          input.shift
          command.new(input, name:, parent: self).()
          true
        end

        handle_no_command_error(token) unless completed
      rescue Samovar::InvalidInputError => e
        puts e.token
        e.command.print_usage
      end

      def handle_no_command_error(cmd)
        require "rake"
        Rake::TaskManager.record_task_metadata = true

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

          if Rake::Task.task_defined?(cmd.split("[")[0])
            rake.top_level
          else
            puts "Unknown task: #{cmd.split("[")[0]}\n\nHere's a list of tasks you can run:"
            display_rake_tasks(rake)
          end
        rescue RuntimeError => e
          # re-raise error unless it's an error through Minitest
          raise e unless e.message.include?("ruby -Ilib:test")

          Bridgetown.logger.error "test aborted!"
          Bridgetown.logger.error e.message
          exit(false)
        end
      end

      def display_rake_tasks(rake)
        rake.options.show_all_tasks = true
        rake.options.show_task_pattern = Regexp.new("")
        rake.options.show_tasks = :tasks
        rake.display_tasks_and_comments
      end

      def load_rake_tasks(rake)
        rake.load_rakefile
        tasks = rake.instance_variable_get(:@tasks)
        rake.instance_variable_set(:@tasks, tasks.reject do |_k, v|
          v.locations.first&.include?("/lib/rails/tasks/") ||
            v.locations.first&.include?("/lib/rake/dsl_definition")
        end)
      end
    end
  end
end

#Bridgetown::Commands2::Application.table[:command].commands["configure"] = Bridgetown::Commands2::Configure
