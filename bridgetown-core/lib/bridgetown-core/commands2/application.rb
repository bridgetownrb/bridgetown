require "samovar"

require_all "bridgetown-core/commands2/concerns"
require "bridgetown-core/commands2/registrations"
require_all "bridgetown-core/commands2"

Samovar::Command.class_eval do
  def self.summary = description
end

# Monkey-patch to support `--key=value`
Samovar::Options.class_eval do
  def parse(input, parent = nil, default = nil)
    values = (default || @defaults).dup

    while option = (@keyed[input.first] || @keyed[input.first&.split("=")&.first])
      # prefix = input.first
      result = option.parse(input)
      if result != nil
        values[option.key] = result
      end
    end

    # Validate required options
    @ordered.each do |option|
      if option.required && !values.key?(option.key)
        raise Samovar::MissingValueError.new(parent, option.key)
      end
    end

    return values
  end   # Generate a string representation for usage output.
end

Samovar::ValueFlag.class_eval do
  # Parse this flag from the input.
  # 
  # @parameter input [Array(String)] The command-line arguments.
  # @returns [String | Symbol | Nil] The parsed value.
  def parse(input)
    if prefix?(input.first)
      # Whether we are expecting to parse a value from input:
      if @value
        # Get the actual value from input:
        flag, value = input.shift(2)
        return value
      else
        # Otherwise, we are just a boolean flag:
        input.shift
        return key
      end
    elsif prefix?(input.first.split("=").first)
      value = input.shift(1)[0].split("=").last
      return value
    end
  end
end

module Bridgetown
  module Commands2
    class Application < Samovar::Command
      self.description =
        "next-generation, progressive site generator & fullstack framework, powered by Ruby"

      def self.registrations = @registrations ||= {}

      def self.register(klass, name, *)
        registrations[name] = klass
      end

      Registrations.load_registrations(self)

      nested(:command, registrations)

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
        puts "Usage:"

        puts "  bridgetown <command> [options]\n\n"
        puts "Commands:"

        commands = self.class.table[:command].commands.to_h do |name, command|
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

        completed = self.class.table[:command].commands.find do |name, command|
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

      def handle_no_command_error(cmd) # rubocop:todo Metrics
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
            puts "Unknown token: #{cmd.split("[")[0]}\n\n"
            print_usage
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
