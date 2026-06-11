# frozen_string_literal: true

# rubocop:disable Style/RedundantBegin, Style/RedundantSelf
module Bridgetown
  module Rack
    class LiveReload
      SLEEP_INTERVAL = 0.5

      def initialize(file_to_check:, errors_file:)
        @file_to_check = file_to_check
        @errors_file = errors_file

        @last_modified = self.current_modified
      end

      def event_stream
        proc do |stream|
          begin
            run_loop(stream)
          ensure
            stream.close
          end
        end
      end

      def threaded_event_stream
        proc do |stream|
          Thread.new do
            run_loop(stream)
          ensure
            stream.close
          end
        end
      end

      private

      def run_loop(stream)
        loop do
          latest_modified = current_modified

          if @last_modified < latest_modified
            stream.write "data: reloaded!\n\n"
            break
          elsif File.exist?(@errors_file)
            stream.write "event: builderror\ndata: #{File.read(@errors_file).to_json}\n\n"
          else
            stream.write "data: #{latest_modified}\n\n"
          end

          sleep SLEEP_INTERVAL
        rescue Errno::EPIPE # User refreshed the page
          break
        end
      end

      def current_modified
        File.exist?(@file_to_check) ? File.stat(@file_to_check).mtime.to_i : 0
      end
    end
  end
end
# rubocop:enable Style/RedundantBegin, Style/RedundantSelf
