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
    # @yield the block will be called when in SSR mode right after the post_read event
    def watch(site, options, &block)
      ENV["LISTEN_GEM_DEBUGGING"] ||= "1" if options["verbose"]

      listen(site, options)

      if site.ssr?
        # We need to trigger pre/post read hooks when SSR reload occurs in order to re-run Builders
        Bridgetown::Hooks.register_one :site, :after_soft_reset, reloadable: false do
          Bridgetown::Hooks.trigger :site, :pre_read, site
          Bridgetown::Hooks.trigger :site, :post_read, site
          block&.call(site)
        end
      end

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
      additional_paths = options.additional_watch_paths
      [
        *site.plugin_manager.plugins_path,
        *options.autoload_paths,
        *additional_paths,
      ].uniq.select do |path|
        Dir.exist?(path)
      end
    end

    # Start a listener to watch for changes and call {#reload_site}
    #
    # @param (see #watch)
    def listen(site, options) # rubocop:disable Metrics/MethodLength
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

        # NOTE: inexplicably, this matcher doesn't work with the Listen gem, so
        # we have to run it here manually
        c.reject! { component_frontend_matcher(options).match? _1 }
        n = c.length
        next if n.zero?

        unless site.ssr?
          Bridgetown.logger.info(
            "Reloading…",
            "#{n} file#{"s" if n > 1} changed at #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
          )
          c.each { |path| Bridgetown.logger.info "", "- #{path["#{site.root_dir}/".length..]}" }
        end

        reload_site(
          site,
          options,
          paths: c,
          fast_refreshable: site.config.fast_refresh && (added + removed).empty?
        )
      end.start
    end

    # Reload the site including plugins and Zeitwerk autoloaders and process it (unless SSR)
    #
    # @param site [Bridgetown::Site] the current site instance
    # @param options [Bridgetown::Configuration] the site configuration
    # @param paths Array<String>
    def reload_site(site, options, paths: [], fast_refreshable: false) # rubocop:todo Metrics/MethodLength
      begin
        time = Time.now
        I18n.reload! # make sure any locale files get read again
        Bridgetown::Current.sites[site.label] = site # needed in SSR mode apparently
        catch :halt do
          unless fast_refreshable
            Bridgetown::Hooks.trigger :site, :pre_reload, site, paths
            Bridgetown::Hooks.clear_reloadable_hooks
            site.loaders_manager.reload_loaders
            Bridgetown::Hooks.trigger :site, :post_reload, site, paths
          end

          if site.ssr?
            site.reset(soft: true)
            return
          end

          if fast_refreshable
            site.fast_refresh(paths, reload_if_needed: true)
          else
            site.process
          end
        end
        Bridgetown.logger.info "Done! 🎉", "#{"Completed".bold.green} in less than " \
                                          "#{(Time.now - time).ceil(2)} seconds."
      rescue StandardError, SyntaxError => e
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
      Array(options["exclude"]).map { |e| Bridgetown.sanitized_path(options["root_dir"], e) }
    end

    # rubocop:disable Layout/LineLength
    def component_frontend_matcher(options)
      # TODO: maybe a negative lookbehind would make this regex cleaner?
      @fematcher ||=
        %r{(#{options[:components_dir]}|#{options[:islands_dir]})/(?:[^.]+|\.(?!dsd))+(\.js|\.jsx|\.js\.rb|\.css)$}
    end
    # rubocop:enable Layout/LineLength

    def to_exclude(options)
      [
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
      end
    end

    def sleep_forever
      sleep 0.5 until shutdown
    end
  end
end
