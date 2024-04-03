# frozen_string_literal: true

module Bridgetown
  module Utils
    module Aux
      def self.with_color(name, message)
        return message unless !name.nil? && Bridgetown::Utils::Ansi::COLORS[name.to_sym]

        Bridgetown::Utils::Ansi.send(name, message)
      end

      def self.running_pids
        @running_pids ||= []
      end

      def self.add_pid(pid)
        running_pids << pid
      end

      def self.run_process(name, color, cmd, env: {})
        @mutex ||= Thread::Mutex.new

        Thread.new do
          rd, wr = IO.pipe("BINARY")
          pid = Process.spawn({ "BRIDGETOWN_NO_BUNDLER_REQUIRE" => nil }.merge(env),
                              cmd, out: wr, err: wr, pgroup: true)
          @mutex.synchronize { add_pid(pid) }

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

      def self.group(&)
        Bridgetown::Deprecator.deprecation_message "Bridgetown::Aux.group method will be removed" \
                                                   "in a future version, use run_process"
        instance_exec(&)
      end

      def self.kill_processes
        Bridgetown.logger.info "Stopping auxiliary processes..."
        running_pids.each do |pid|
          Process.kill("SIGTERM", -Process.getpgid(pid))
        rescue Errno::ESRCH, Errno::EPERM, Errno::ECHILD # rubocop:disable Lint/SuppressedException
        end
      end
    end
  end
end
