# frozen_string_literal: true

require "bridgetown"

namespace :profile do
  desc "Profile allocations from a build session"
  task :memory, [:file, :mode] do |_t, args|
    args.with_defaults(file: "memprof.txt", mode: "lite")

    build_phases = [:reset, :read, :generate, :render, :cleanup, :write]

    if args.mode == "lite"
      build_phases -= [:render, :generate]
    end

    require "memory_profiler"

    report = MemoryProfiler.report do
      site = Bridgetown::Site.new(
        Bridgetown.configuration(
          "source"      => File.expand_path("../docs", __dir__),
          "destination" => File.expand_path("../docs/_site", __dir__)
        )
      )

      Bridgetown.logger.info "Source:", site.source
      Bridgetown.logger.info "Destination:", site.dest
      Bridgetown.logger.info "Plugins and Cache:", "enabled"
      Bridgetown.logger.info "Profiling phases:", build_phases.join(", ").cyan
      Bridgetown.logger.info "Profiling..."

      build_phases.each { |phase| site.send phase }

      Bridgetown.logger.info "", "and done. Generating results.."
      Bridgetown.logger.info ""
    end

    if ENV["CI"]
      report.pretty_print(scale_bytes: true, color_output: false, normalize_paths: true)
    else
      FileUtils.mkdir_p("tmp")
      report_file = File.join("tmp", args.file)

      total_allocated_output = report.scale_bytes(report.total_allocated_memsize)
      total_retained_output  = report.scale_bytes(report.total_retained_memsize)

      Bridgetown.logger.info "Total allocated: #{total_allocated_output} (#{report.total_allocated} objects)".cyan
      Bridgetown.logger.info "Total retained:  #{total_retained_output} (#{report.total_retained} objects)".cyan

      report.pretty_print(to_file: report_file, scale_bytes: true, normalize_paths: true)
      Bridgetown.logger.info "\nDetailed Report saved into:", report_file.cyan
    end
  end
end
