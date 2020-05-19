# frozen_string_literal: true

module Bridgetown
  module Commands
    class Build < Thor::Group
      Registrations.register do
        register(Build, "build", "build", Build.summary)
      end

      class_option :watch,
                   type: :boolean,
                   aliases: "-w",
                   desc: "Watch for changes and rebuild"

      extend BuildOptions
      extend Summarizable
      include OptionsConfigurable

      def self.banner
        "bridgetown build [options]"
      end

      summary "Build your site and save to destination folder"

      # Build your bridgetown site
      # Continuously watch if `watch` is set to true in the config.
      def build
        Bridgetown.logger.adjust_verbosity(options)

        Bridgetown.logger.info "Starting:", "Bridgetown v#{Bridgetown::VERSION.magenta}" \
                               " (codename \"#{Bridgetown::CODE_NAME.yellow}\")"

        config_options = Serve.loaded_config || configuration_from_options(options)
        config_options["serving"] = false unless config_options["serving"]
        @site = Bridgetown::Site.new(config_options)

        if config_options.fetch("skip_initial_build", false)
          Bridgetown.logger.warn "Build Warning:", "Skipping the initial build." \
                                 " This may result in an out-of-date site."
        else
          build_site(config_options)
        end

        if config_options.fetch("detach", false)
          Bridgetown.logger.info "Auto-regeneration:",
                                 "disabled when running server detached."
        elsif config_options.fetch("watch", false)
          watch_site(config_options)
        else
          Bridgetown.logger.info "Auto-regeneration:", "disabled. Use --watch to enable."
        end
      end

      protected

      # Build your Bridgetown site.
      #
      # options - A Hash of options passed to the command or loaded from config
      #
      # Returns nothing.
      def build_site(config_options)
        t = Time.now
        display_folder_paths(config_options)
        if config_options["unpublished"]
          Bridgetown.logger.info "Unpublished mode:",
                                 "enabled. Processing documents marked unpublished"
        end
        incremental = config_options["incremental"]
        Bridgetown.logger.info "Incremental build:",
                               (incremental ? "enabled" : "disabled. Enable with --incremental")
        Bridgetown.logger.info "Generating…"
        @site.process
        Bridgetown.logger.info "Done! 🎉", "#{"Completed".green} in less than" \
                                " #{(Time.now - t).ceil(2)} seconds."
      end

      # Watch for file changes and rebuild the site.
      #
      # options - A Hash of options passed to the command or loaded from config
      #
      # Returns nothing.
      def watch_site(config_options)
        # Warn Windows users that they might need to upgrade.
        if Utils::Platforms.bash_on_windows?
          Bridgetown.logger.warn "",
                                 "Auto-regeneration may not work on some Windows versions."
          Bridgetown.logger.warn "",
                                 "Please see: https://github.com/Microsoft/BashOnWindows/issues/216"
          Bridgetown.logger.warn "",
                                 "If it does not work, please upgrade Bash on Windows or "\
                                 "run Bridgetown with --no-watch."
        end

        Bridgetown::Watcher.watch(@site, config_options)
      end

      # Display the source and destination folder paths
      #
      # options - A Hash of options passed to the command
      #
      # Returns nothing.
      def display_folder_paths(config_options)
        source = File.expand_path(config_options["source"])
        destination = File.expand_path(config_options["destination"])
        Bridgetown.logger.info "Environment:", Bridgetown.environment.cyan
        Bridgetown.logger.info "Source:", source
        Bridgetown.logger.info "Destination:", destination
        # TODO: work with arrays
        if config_options["plugins_dir"].is_a?(String)
          plugins_dir = File.expand_path(config_options["plugins_dir"])
          Bridgetown.logger.info "Custom Plugins:", plugins_dir if Dir.exist?(plugins_dir)
        end
      end
    end
  end
end
