# frozen_string_literal: true

module Bridgetown
  module Utils
    module Aux
      extend Bridgetown::Utils::PidTracker

      def self.with_color(name, message)
        return message unless !name.nil? && Bridgetown::Foundation::Ansi::COLORS[name.to_sym]

        Bridgetown::Foundation::Ansi.send(name, message)
      end

      def self.run_process(name, color, cmd, env: {})
        @mutex ||= Thread::Mutex.new

        Thread.new do
          rd, wr = IO.pipe("BINARY")
          pid = Process.spawn({ "BRIDGETOWN_NO_BUNDLER_REQUIRE" => nil }.merge(env),
                              cmd, out: wr, err: wr, pgroup: true)
          @mutex.synchronize { add_pid(pid, file: :aux) }

          loop do
            line = rd.gets
            line.to_s.lines.map(&:chomp).each do |message|
              next if name == "Frontend" && %r{ELIFECYCLE.*?Command failed}.match?(message)

              output = +""
              output << with_color(color, "[#{name}] ") if color
              output << message
              @mutex.synchronize do
                $stdout.puts output
                $stdout.flush
              end
            end
          end
        end
      end

      def self.kill_processes
        Bridgetown.logger.info "Stopping auxiliary processes..."

        read_pidfile(:aux).each do |pid|
          Process.kill("SIGTERM", -Process.getpgid(pid.to_i))
        rescue Errno::ESRCH, Errno::EPERM, Errno::ECHILD # rubocop:disable Lint/SuppressedException
        ensure
          remove_pidfile :aux
        end
      end
    end
  end
end
