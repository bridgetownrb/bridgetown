# frozen_string_literal: true

module Bridgetown
  class Container::Interceptor
    attr_reader :reader, :writer

    def self.with_tag(tag, color:)
      new(tag, color: color)
    end

    def hook
      $stdin.reopen(@reader)
      $stdout.reopen(@writer)
      $stderr.reopen(@writer)
    end

    private

    def initialize(tag, color:)
      @tag = tag
      @color = color

      @reader, @writer = IO.pipe
      listen
    end

    def listen
      Thread.new do
        loop do
          line = @reader.gets
          line.to_s.lines.map(&:chomp).each do |message|
            output = +""
            output << "[#{@tag}] ".send(@color)
            output << message

            $stdout.puts output
            $stdout.flush
          end
        end
      end
    end
  end
end
