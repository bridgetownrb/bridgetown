# frozen_string_literal: true

module Bridgetown
  class LiquidRenderer
    # TODO: deprecate or move to a separate repo/plugin
    class Table
      GAUGES = [:count, :bytes, :time].freeze

      def initialize(stats)
        @stats = stats
      end

      def to_s(num_of_rows = 50)
        tabulate(data_for_table(num_of_rows))
      end

      private

      def tabulate(data)
        unless defined?(Terminal::Table)
          Bridgetown::Utils::RequireGems.require_with_graceful_fail "terminal-table"
        end

        header = data.shift
        footer = data.pop
        output = +"\n"

        table = Terminal::Table.new do |t|
          t << header
          t << :separator
          data.each { |row| t << row }
          t << :separator
          t << footer
          t.style = { alignment: :right, border_top: false, border_bottom: false }
          t.align_column(0, :left)
        end

        output << table.to_s << "\n"
      end

      # rubocop:disable Metrics/AbcSize
      def data_for_table(num_of_rows)
        sorted = @stats.sort_by { |_, file_stats| -file_stats[:time] }
        sorted = sorted.slice(0, num_of_rows)

        table  = [header_labels]
        totals = Hash.new { |hash, key| hash[key] = 0 }

        sorted.each do |filename, file_stats|
          GAUGES.each { |gauge| totals[gauge] += file_stats[gauge] }
          row = []
          row << filename
          row << file_stats[:count].to_s
          row << format_bytes(file_stats[:bytes])
          row << format("%.3f", file_stats[:time])
          table << row
        end

        footer = []
        footer << "TOTAL (for #{sorted.size} files)"
        footer << totals[:count].to_s
        footer << format_bytes(totals[:bytes])
        footer << format("%.3f", totals[:time])
        table  << footer
      end
      # rubocop:enable Metrics/AbcSize

      def header_labels
        GAUGES.map { |gauge| gauge.to_s.capitalize }.unshift("Filename")
      end

      def format_bytes(bytes)
        bytes /= 1024.0
        format("%.2fK", bytes)
      end
    end
  end
end
