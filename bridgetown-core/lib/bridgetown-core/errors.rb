# frozen_string_literal: true

module Bridgetown
  module Errors
    FatalException = Class.new(::RuntimeError)

    DropMutationException       = Class.new(FatalException)
    InvalidPermalinkError       = Class.new(FatalException)
    InvalidYAMLFrontMatterError = Class.new(FatalException)
    MissingDependencyException  = Class.new(FatalException)

    InvalidDateError            = Class.new(FatalException)
    InvalidPostNameError        = Class.new(FatalException)
    PostURLError                = Class.new(FatalException)
    InvalidURLError             = Class.new(FatalException)
    InvalidConfigurationError   = Class.new(FatalException)

    def self.print_build_error(exc, trace: false, logger: Bridgetown.logger)
      logger.error "Exception raised:", exc.class.to_s.bold
      logger.error exc.message.reset_ansi

      trace_args = ["-t", "--trace"]
      print_trace_msg = true
      traces = if trace || ARGV.find { |arg| trace_args.include?(arg) }
                 print_trace_msg = false
                 exc.backtrace
               else
                 exc.backtrace[0..4]
               end
      traces.each_with_index do |backtrace_line, index|
        logger.error "#{index + 1}:", backtrace_line.reset_ansi
      end

      return unless print_trace_msg

      logger.warn "Backtrace:", "Use the --trace option for complete information."
    end
  end
end
