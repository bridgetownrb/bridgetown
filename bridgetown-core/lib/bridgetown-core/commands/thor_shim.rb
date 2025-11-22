# frozen_string_literal: true

require "samovar"
require "freyia"

unless defined?(Thor)
  class ThorishCommand < Samovar::Command
    Actions = Freyia::Setup

    def self.inherited(klass)
      super

      klass.nested :command, {}

      klass.define_method :call do
        Bridgetown::Deprecator.deprecation_message(
          "The #{self.class} command is using the Thor shim. Please migrate to using the " \
          "Samovar-based command API in Bridgetown 2.1+. The Thor shim will be removed " \
          "in a later Bridgetown release."
        )

        if @command
          @command.()
        else
          print_usage
        end
      end
    end

    def self.desc(name, description)
      @next_cmd_name = name
      @next_cmd_description = description
    end

    def self.option(name, desc: "...", **kwargs, &block)
      @next_cmd_options ||= []
      @next_cmd_options << { args: [name, desc], kwargs:, block: }
    end

    def self.method_added(meth) # rubocop:disable Metrics
      super

      return unless @next_cmd_name

      next_cmd_name = @next_cmd_name
      new_cmd = Class.new(Samovar::Command)
      new_cmd.define_method(:call) do
        parent.instance_variable_set(:@options, @options)
        parent.send(next_cmd_name)
      end
      new_cmd.description = @next_cmd_description

      if @next_cmd_options&.empty?&.!
        next_cmd_options = @next_cmd_options
        new_cmd.options do
          next_cmd_options.each do |opt|
            name = opt[:args].shift
            if !opt[:kwargs][:type] || opt[:kwargs][:type] != :boolean
              # TODO: support other value types
              name = "#{name} <text>"
            end

            option("--#{name}", opt[:args][1], required: opt[:kwargs][:required])
          end
        end
      end

      table[:command].commands[next_cmd_name] = new_cmd

      @next_cmd_name = nil
      @next_cmd_description = nil
    end

    attr_reader :options
  end

  Thor = ThorishCommand
end
