# frozen_string_literal: true

module Bridgetown
  module Watcher
    extend self

    class << self
      attr_accessor :shutdown
    end

    # Continuously watch for file changes and rebuild the site whenever a change is detected.
    #
    # @param site [Bridgetown::Site] the current site instance
    # @param options [Bridgetown::Configuration] the site configuration
    def watch(site, options)
      ENV["LISTEN_GEM_DEBUGGING"] ||= "1" if options["verbose"]

      listen(site, options)

      Bridgetown.logger.info "Watcher:", "enabled." unless options[:using_puma]

      return if options[:serving]

      trap("INT") do
        self.shutdown = true
      end

      sleep_forever
    end

    # Return a list of load paths which should be watched for changes
    #
    # @param (see #watch)
    def load_paths_to_watch(site, options)
      site.plugin_manager.plugins_path.select { |path| Dir.exist?(path) }
        .then do |paths|
          (paths + options.autoload_paths).uniq
        end
    end

    # Start a listener to watch for changes and call {#reload_site}
    #
    # @param (see #watch)
    def listen(site, options)
      bundling_path = site.frontend_bundling_path
      FileUtils.mkdir_p(bundling_path)
      Listen.to(
        options["source"],
        bundling_path,
        *load_paths_to_watch(site, options),
        ignore: listen_ignore_paths(options),
        force_polling: options["force_polling"]
      ) do |modified, added, removed|
        c = modified + added + removed
        n = c.length

        unless site.ssr?
          Bridgetown.logger.info(
            "Reloading…",
            "#{n} file#{"s" if c.length > 1} changed at #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
          )
          c.each { |path| Bridgetown.logger.info "", "- #{path["#{site.root_dir}/".length..]}" }
        end

        reload_site(site, options, paths: c)
      end.start
    end

    # Reload the site including plugins and Zeitwerk autoloaders and process it (unless SSR)
    #
    # @param site [Bridgetown::Site] the current site instance
    # @param options [Bridgetown::Configuration] the site configuration
    # @param paths Array<String>
    def reload_site(site, options, paths: []) # rubocop:todo Metrics/MethodLength
      begin
        time = Time.now
        I18n.reload! # make sure any locale files get read again
        Bridgetown::Current.site = site # needed in SSR mode apparently
        catch :halt do
          Bridgetown::Hooks.trigger :site, :pre_reload, site, paths
          Bridgetown::Hooks.clear_reloadable_hooks
          site.plugin_manager.reload_plugin_files
          site.loaders_manager.reload_loaders
          Bridgetown::Hooks.trigger :site, :post_reload, site, paths

          if site.ssr?
            site.reset(soft: true)
            return
          end

          site.process
        end
        Bridgetown.logger.info "Done! 🎉", "#{"Completed".bold.green} in less than" \
                                          " #{(Time.now - time).ceil(2)} seconds."
      rescue StandardError => e
        Bridgetown::Errors.print_build_error(e, trace: options[:trace])
      end
      Bridgetown.logger.info ""
    end

    private

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
    def listen_ignore_paths(options)
      source = Pathname.new(options["source"]).expand_path
      paths  = to_exclude(options)

      paths.filter_map do |p|
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
      end + [%r!^\.bridgetown-metadata!]
    end

    def sleep_forever
      sleep 0.5 until shutdown
    end
  end
end
