# frozen_string_literal: true

require "zeitwerk"
require "listen"
require "roda"
require "json"
require "roda/plugins/public"

require_relative "static_indexes"

module Bridgetown
  module Rack
    # Extension to add easy color support to IO streams
    module Colors
      ANSI = {
        reset: 0,
        black: 30,
        red: 31,
        green: 32,
        yellow: 33,
        blue: 34,
        magenta: 35,
        cyan: 36,
        white: 37,
        bright_black: 30,
        bright_red: 31,
        bright_green: 32,
        bright_yellow: 33,
        bright_blue: 34,
        bright_magenta: 35,
        bright_cyan: 36,
        bright_white: 37,
      }.freeze

      def self.enable(io)
        io.extend(self)
      end

      def color?
        isatty && ENV["TERM"]
      end

      def color(name)
        return "" unless color?
        return "" unless ansi = ANSI[name.to_sym]

        "\e[#{ansi}m"
      end
    end

    def self.run_process(name, color, cmd)
      Thread.new do
        rd, wr = IO.pipe("BINARY")
        pid = Process.spawn(cmd, out: wr, err: wr)

        loop do
          line = rd.gets
          line.to_s.lines.map(&:chomp).each do |message|
            output = +""
            output << $stdout.color(color) unless color.nil?
            output << "[#{name}] " unless color.nil?
            output << $stdout.color(:reset) unless color.nil?
            output << message
            @mutex.synchronize do
              $stdout.puts output
              $stdout.flush
            end
          end
        end
      end
    end

    def self.boot(backend: "backend", &block)
      backend_path = File.join(Dir.pwd, backend, "config", "application.rb")
      load backend_path if File.exist?(backend_path)

      Roda.opts[:public_root] = "output"

      loader = Zeitwerk::Loader.new
      loader.push_dir(File.join(Dir.pwd, "config"))
      loader.enable_reloading
      loader.setup

      listener = Listen.to(File.join(Dir.pwd, "config")) do |_modified, _added, _removed|
        loader.reload
      end
      listener.start

      @mutex = Thread::Mutex.new
      Colors.enable($stdout)

      Signal.trap("SIGINT") do
        puts " - Stopping Bridgetown & Puma..."
        raise Interrupt
      end

      instance_exec(&block)
    end
  end
end
