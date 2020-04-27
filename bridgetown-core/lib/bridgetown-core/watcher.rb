# frozen_string_literal: true

require "listen"

module Bridgetown
  module Watcher
    extend self

    # Public: Continuously watch for file changes and rebuild the site
    # whenever a change is detected.
    #
    # site    - The current site instance
    # options - A Hash containing the site configuration
    #
    # Returns nothing.
    def watch(site, options)
      ENV["LISTEN_GEM_DEBUGGING"] ||= "1" if options["verbose"]

      listener = build_listener(site, options)
      listener.start

      Bridgetown.logger.info "Auto-regeneration:", "enabled."

      unless options["serving"]
        trap("INT") do
          listener.stop
          Bridgetown.logger.info "", "Halting auto-regeneration."
          exit 0
        end

        sleep_forever
      end
    rescue ThreadError
      # You pressed Ctrl-C, oh my!
    end

    private

    def build_listener(site, options)
      webpack_path = site.in_root_dir(".bridgetown-webpack")
      FileUtils.mkdir(webpack_path) unless Dir.exist?(webpack_path)
      Listen.to(
        options["source"],
        site.in_root_dir(".bridgetown-webpack"),
        ignore: listen_ignore_paths(options),
        force_polling: options["force_polling"],
        &listen_handler(site)
      )
    end

    def listen_handler(site)
      proc do |modified, added, removed|
        t = Time.now
        c = modified + added + removed
        n = c.length

        Bridgetown.logger.info "Regenerating…"
        Bridgetown.logger.info "", "#{n} file(s) changed at #{t.strftime("%Y-%m-%d %H:%M:%S")}"

        c.each { |path| Bridgetown.logger.info "", path["#{site.root_dir}/".length..-1] }
        process(site, t)
      end
    end

    def normalize_encoding(obj, desired_encoding)
      case obj
      when Array
        obj.map { |entry| entry.encode!(desired_encoding, entry.encoding) }
      when String
        obj.encode!(desired_encoding, obj.encoding)
      end
    end

    def custom_excludes(options)
      Array(options["exclude"]).map { |e| Bridgetown.sanitized_path(options["source"], e) }
    end

    def config_files(options)
      %w(yml yaml toml).map do |ext|
        Bridgetown.sanitized_path(options["source"], "_config.#{ext}")
      end
    end

    def to_exclude(options)
      [
        config_files(options),
        options["destination"],
        custom_excludes(options),
      ].flatten
    end

    # Paths to ignore for the watch option
    #
    # options - A Hash of options passed to the command
    #
    # Returns a list of relative paths from source that should be ignored
    # rubocop: disable Metrics/AbcSize
    def listen_ignore_paths(options)
      source = Pathname.new(options["source"]).expand_path
      paths  = to_exclude(options)

      paths.map do |p|
        absolute_path = Pathname.new(normalize_encoding(p, options["source"].encoding)).expand_path
        next unless absolute_path.exist?

        begin
          relative_path = absolute_path.relative_path_from(source).to_s
          relative_path = File.join(relative_path, "") if absolute_path.directory?
          unless relative_path.start_with?("../")
            path_to_ignore = %r!^#{Regexp.escape(relative_path)}!
            Bridgetown.logger.debug "Watcher:", "Ignoring #{path_to_ignore}"
            path_to_ignore
          end
        rescue ArgumentError
          # Could not find a relative path
        end
      end.compact + [%r!^\.bridgetown\-metadata!]
    end
    # rubocop:enable Metrics/AbcSize

    def sleep_forever
      loop { sleep 1000 }
    end

    def process(site, time)
      begin
        site.process
        Bridgetown.logger.info "Done! 🎉", "#{"Completed".green} in less than" \
                               " #{(Time.now - time).ceil(2)} seconds."
      rescue StandardError => e
        Bridgetown.logger.warn "Error:", e.message
        Bridgetown.logger.warn "Error:", "Run bridgetown build --trace for more information."
      end
      Bridgetown.logger.info ""
    end
  end
end
