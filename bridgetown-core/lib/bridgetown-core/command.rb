# frozen_string_literal: true

require "samovar"
require "freyia"

# Monkey-patch to use cyan instead of blue formatting
Samovar::Output::UsageFormatter.class_eval do
  # Initialize a new usage formatter.
  #
  # @parameter rows [Rows] The rows to format.
  # @parameter output [IO] The output stream to print to.
  def initialize(output)
    @output = output
    @width = 80
    @first = true

    @terminal = Console::Terminal.for(@output)
    @terminal[:header] = @terminal.style(:cyan, nil, :bright)
    #@terminal[:description] = @terminal.style(:cyan)
    @terminal[:options] = @terminal.style(:cyan)
    @terminal[:error] = @terminal.style(:red)
  end

  map(Samovar::Output::Row) do |row, rows|
    row[1] = row[1].reset_ansi if row[1]
    @terminal.puts "#{rows.indentation}#{row.align(rows.columns)}", style: :options
  end
end

# Monkey-patch to support `--key=value`
Samovar::Options.class_eval do
  def parse(input, parent = nil, default = nil) # rubocop:disable Metrics
    values = (default || @defaults).dup

    while option = @keyed[input.first] || @keyed[input.first&.split("=")&.first] # rubocop:disable Lint/AssignmentInCondition
      result = option.parse(input)
      values[option.key] = result unless result.nil?
    end

    # Validate required options
    @ordered.each do |option|
      if option.required && !values.key?(option.key)
        raise Samovar::MissingValueError.new(parent, option.key)
      end
    end

    values
  end
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
        _, value = input.shift(2)
        value
      else
        # Otherwise, we are just a boolean flag:
        input.shift
        key
      end
    elsif prefix?(input.first.split("=").first)
      input.shift(1)[0].split("=").last

    end
  end
end

module Bridgetown
  class Command < Samovar::Command
    def self.summary = description

    # Compatibility syntax to execute commands.
    # It's recommended you use Samovar's more idiomatic `CmdClass[*args].call` syntax instead
    def self.start(args = []) = self[*args].call

    # Samovar shows all command options by default when printing out a command name string.
    # We want to hide that part of the output, as options are already listed out separately
    def self.command_line(name)
      table = self.table.merged

      usage_string = table.each.collect do |row|
        next "" if row.is_a?(Samovar::Options)

        row.to_s
      end.reject(&:empty?).join(" ")

      "#{name} #{usage_string}"
    end
  end
end
