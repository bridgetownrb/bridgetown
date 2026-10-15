# frozen_string_literal: true

module Bridgetown
  class LogWriter < ::Logger
    def initialize
      super($stdout, formatter: default_formatter)
    end

    def set_prefix(prefix, color:)
      prefix = "[#{prefix}]".send(color)

      self.formatter = proc do |_, _, _, msg|
        "#{prefix} #{msg}"
      end
    end

    def remove_prefix
      self.formatter = default_formatter
    end

    def add(severity, message = nil, progname = nil) # rubocop:disable Naming/PredicateMethod
      severity ||= UNKNOWN
      @logdev = logdevice(severity)

      return true if @logdev.nil? || severity < @level

      progname ||= @progname
      if message.nil?
        if block_given?
          message = yield
        else
          message = progname
          progname = @progname
        end
      end
      @logdev.puts(
        format_message(format_severity(severity), Time.now, progname, message)
      )
      true
    end

    # Log a `WARN` message
    def warn(progname = nil, &)
      add(WARN, nil, progname.yellow, &)
    end

    # Log an `ERROR` message
    def error(progname = nil, &)
      add(ERROR, nil, progname.red, &)
    end

    def close
      # No LogDevice in use
    end

    private

    def default_formatter
      proc { |_, _, _, msg| msg.to_s }
    end

    def logdevice(severity)
      if severity > INFO
        $stderr
      else
        $stdout
      end
    end
  end
end
