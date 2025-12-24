# frozen_string_literal: true

require "helper"

class TestLogAdapter < BridgetownUnitTest
  class LoggerDouble
    attr_accessor :level

    def debug(*); end

    def info(*); end

    def warn(*); end

    def error(*); end
  end

  describe "#log_level=" do
    it "sets the writers logging level" do
      subject = Bridgetown::LogAdapter.new(LoggerDouble.new)
      subject.log_level = :error
      assert_equal Bridgetown::LogAdapter::LOG_LEVELS[:error], subject.writer.level
    end
  end

  describe "#adjust_verbosity" do
    it "sets the writers logging level to error when quiet" do
      subject = Bridgetown::LogAdapter.new(LoggerDouble.new)
      subject.adjust_verbosity(quiet: true)
      assert_equal Bridgetown::LogAdapter::LOG_LEVELS[:error], subject.writer.level
    end

    it "sets the writers logging level to debug when verbose" do
      subject = Bridgetown::LogAdapter.new(LoggerDouble.new)
      subject.adjust_verbosity(verbose: true)
      assert_equal Bridgetown::LogAdapter::LOG_LEVELS[:debug], subject.writer.level
    end

    it "sets the writers logging level to error when quiet and verbose are both set" do
      subject = Bridgetown::LogAdapter.new(LoggerDouble.new)
      subject.adjust_verbosity(quiet: true, verbose: true)
      assert_equal Bridgetown::LogAdapter::LOG_LEVELS[:error], subject.writer.level
    end

    it "does not change the writer's logging level when neither verbose or quiet" do
      subject = Bridgetown::LogAdapter.new(LoggerDouble.new)
      original_level = subject.writer.level
      refute_equal Bridgetown::LogAdapter::LOG_LEVELS[:error], subject.writer.level
      refute_equal Bridgetown::LogAdapter::LOG_LEVELS[:debug], subject.writer.level
      subject.adjust_verbosity(quiet: false, verbose: false)
      assert_equal original_level, subject.writer.level
    end

    it "calls #debug on writer return true" do
      writer = Minitest::Mock.new(LoggerDouble.new)
      writer.expect :debug, true, ["  Logging at level: debug"]

      logger = Bridgetown::LogAdapter.new(writer, :debug)
      assert logger.adjust_verbosity
      writer.verify
    end
  end

  describe "#debug" do
    it "calls #debug on writer return true" do
      writer = Minitest::Mock.new(LoggerDouble.new)
      writer.expect :debug, true, ["#{"topic ".rjust(20)}log message"]
      logger = Bridgetown::LogAdapter.new(writer, :debug)

      assert logger.debug("topic", "log message")
    end
  end

  describe "#info" do
    it "calls #info on writer return true" do
      writer = Minitest::Mock.new(LoggerDouble.new)
      writer.expect :info, true, ["#{"topic ".rjust(20)}log message"]
      logger = Bridgetown::LogAdapter.new(writer, :info)

      assert logger.info("topic", "log message")
    end
  end

  describe "#warn" do
    it "calls #warn on writer return true" do
      writer = Minitest::Mock.new(LoggerDouble.new)
      writer.expect :warn, true, ["#{"topic ".rjust(20)}log message"]
      logger = Bridgetown::LogAdapter.new(writer, :warn)

      assert logger.warn("topic", "log message")
    end
  end

  describe "#error" do
    it "calls #error on writer return true" do
      writer = Minitest::Mock.new(LoggerDouble.new)
      writer.expect :error, true, ["#{"topic ".rjust(20)}log message"]
      logger = Bridgetown::LogAdapter.new(writer, :error)

      assert logger.error("topic", "log message")
    end
  end

  describe "#abort_with" do
    it "calls #error and abort" do
      logger = Bridgetown::LogAdapter.new(LoggerDouble.new, :error)
      mock = Minitest::Mock.new
      mock.expect :call, true, ["topic", "log message"]
      logger.stub :error, mock do
        assert_raises(SystemExit) { logger.abort_with("topic", "log message") }
      end
    end
  end

  describe "#messages" do
    it "returns an array" do
      assert_equal [], Bridgetown::LogAdapter.new(LoggerDouble.new).messages
    end

    it "stores each log value in the array" do
      logger = Bridgetown::LogAdapter.new(LoggerDouble.new, :debug)
      values = %w(one two three four)
      logger.debug(values[0])
      logger.info(values[1])
      logger.warn(values[2])
      logger.error(values[3])
      assert_equal values.map { |value| "#{value} ".rjust(20) }, logger.messages
    end
  end

  describe "#write_message?" do
    it "returns false up to the desired logging level" do
      subject = Bridgetown::LogAdapter.new(LoggerDouble.new, :warn)
      refute subject.write_message?(:debug), "Should not print debug messages"
      refute subject.write_message?(:info), "Should not print info messages"
      assert subject.write_message?(:warn), "Should print warn messages"
      assert subject.write_message?(:error), "Should print error messages"
    end
  end
end
