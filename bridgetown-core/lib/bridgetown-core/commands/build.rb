# frozen_string_literal: true

require "bridgetown-core/commands/start"

module Bridgetown
  module Commands
    class Build < Bridgetown::Command
      include ConfigurationOverridable

      self.description = "Build your site and save to destination folder"

      options do
        BuildOptions.include_options(self)
        Start::StartOptions.include_options(self) if ARGV[0] == "start"
        option "-w/--watch", "Watch for changes and rebuild"
      end

      def call # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        Bridgetown.logger.adjust_verbosity(**options)
        config_options = configuration_with_overrides(
          options, Bridgetown::Current.preloaded_configuration
        )
        config_options.run_initializers! context: :static

        if config_options["plugins_dir"].is_a?(String)
          plugins_dir = File.expand_path(config_options["plugins_dir"])
          Bridgetown.logger.info "Custom Plugins:", plugins_dir if Dir.exist?(plugins_dir)
        end

        site = Bridgetown::Site.new(config_options)
        site.build

        if options[:watch]
          container = Bridgetown::Container.new

          container.add_routine(Routines::SiteWatcher.new(site: site))
          container.add_routine(Routines::FrontendWatcher.new(site: site))

          container.run
          container.wait
        else
          Bridgetown.logger.info \
            "Auto-regeneration:", "disabled. Use --watch to enable."
        end
      end
    end

    register_command :build, Build
  end
end
