# frozen_string_literal: true

module Bridgetown
  class LogAdapter
    attr_reader :writer, :messages, :level

    LOG_LEVELS = {
      debug: ::Logger::DEBUG,
      info: ::Logger::INFO,
      warn: ::Logger::WARN,
      error: ::Logger::ERROR,
    }.freeze

    # Create a new instance of a log writer
    #
    # @param writer [Logger] compatible instance
    # @param log_level [Symbol] the log level (`debug` | `info` | `warn` | `error`)
    def initialize(writer, level = :info)
      @messages = []
      @writer = writer
      self.log_level = level
    end

    # Set the log level on the writer
    #
    # @param log_level [Symbol] the log level (`debug` | `info` | `warn` | `error`)
    def log_level=(level)
      writer.level = level if level.is_a?(Integer) && level.between?(0, 3)
      writer.level = LOG_LEVELS[level] ||
        raise(ArgumentError, "unknown log level")
      @level = level
    end

    def adjust_verbosity(options = {})
      # Quiet always wins.
      if options[:quiet]
        self.log_level = :error
      elsif options[:verbose]
        self.log_level = :debug
      end
      debug "Logging at level:", LOG_LEVELS.key(writer.level).to_s
    end

    # Print a debug message
    #
    # @param topic [String] e.g. "Configuration file", "Deprecation", etc.
    # @param message [String] the message detail
    def debug(topic, message = nil, &)
      write(:debug, topic, message, &)
    end

    # Print an informational message
    #
    # @param topic [String] e.g. "Configuration file", "Deprecation", etc.
    # @param message [String] the message detail
    def info(topic, message = nil, &)
      write(:info, topic, message, &)
    end

    # Print a warning message
    #
    # @param topic [String] e.g. "Configuration file", "Deprecation", etc.
    # @param message [String] the message detail
    def warn(topic, message = nil, &)
      write(:warn, topic, message, &)
    end

    # Print an error message
    #
    # @param topic [String] e.g. "Configuration file", "Deprecation", etc.
    # @param message [String] the message detail
    def error(topic, message = nil, &)
      write(:error, topic, message, &)
    end

    # Print an error message and immediately abort the process
    #
    # @param topic [String] e.g. "Configuration file", "Deprecation", etc.
    # @param message [String] the message detail
    def abort_with(topic, message = nil, &)
      error(topic, message, &)
      abort
    end

    # Build a topic method
    #
    # @param topic [String] e.g. "Configuration file", "Deprecation", etc.
    # @param message [String] the message detail
    # @return [String] the formatted message
    def message(topic, message = nil)
      raise ArgumentError, "block or message, not both" if block_given? && message

      message = yield if block_given?
      message = message.to_s.gsub(%r!\s+!, " ")
      topic = formatted_topic(topic, block_given?)
      out = topic + message
      messages << out
      out
    end

    # Format the topic
    #
    # @param topic [String] e.g. "Configuration file", "Deprecation", etc.
    # @param colon [Boolean]
    # @return [String] formatted topic statement
    def formatted_topic(topic, colon = false) # rubocop:disable Style/OptionalBooleanParameter
      "#{topic}#{colon ? ": " : " "}".rjust(20)
    end

    # Check if the message should be written given the log level
    #
    # @param level_of_message [Symbol] the message level (`debug` | `info` | `warn` | `error`)
    # @return [Boolean] whether the message should be written to the log
    def write_message?(level_of_message)
      LOG_LEVELS.fetch(level) <= LOG_LEVELS.fetch(level_of_message)
    end

    # Log a message. If a block is provided containing the message, use that instead.
    #
    # @param level_of_message [Symbol] the message level (`debug` | `info` | `warn` | `error`)
    # @param topic [String] e.g. "Configuration file", "Deprecation", etc.
    # @param message [String] the message detail
    # @return [BasicObject] false if the message was not written, otherwise returns the value of
    #   calling the appropriate writer method, e.g. writer.info.
    def write(level_of_message, topic, message = nil, &)
      return false unless write_message?(level_of_message)

      writer.public_send(level_of_message, message(topic, message, &))
    end
  end
end
