# frozen_string_literal: true

module Bridgetown
  class Command
    class << self
      # A list of subclasses of Bridgetown::Command
      def subclasses
        @subclasses ||= []
      end

      # Keep a list of subclasses of Bridgetown::Command every time it's inherited
      # Called automatically.
      #
      # base - the subclass
      #
      # Returns nothing
      def inherited(base)
        subclasses << base
        super(base)
      end

      # Run Site#process and catch errors
      #
      # site - the Bridgetown::Site object
      #
      # Returns nothing
      def process_site(site)
        site.process
      rescue Bridgetown::Errors::FatalException => e
        Bridgetown.logger.error "ERROR:", "YOUR SITE COULD NOT BE BUILT:"
        Bridgetown.logger.error "", "------------------------------------"
        Bridgetown.logger.error "", e.message
        exit(1)
      end

      # Create a full Bridgetown configuration with the options passed in as overrides
      #
      # options - the configuration overrides
      #
      # Returns a full Bridgetown configuration
      def configuration_from_options(options)
        return options if options.is_a?(Bridgetown::Configuration)

        Bridgetown.configuration(options)
      end

      # Add common options to a command for building configuration
      #
      # cmd - the Bridgetown::Command to add these options to
      #
      # Returns nothing
      # rubocop:disable Metrics/MethodLength
      def add_build_options(cmd)
        cmd.option "config", "--config CONFIG_FILE[,CONFIG_FILE2,...]",
                   Array, "Custom configuration file"
        cmd.option "destination", "-d", "--destination DESTINATION",
                   "The current folder will be generated into DESTINATION"
        cmd.option "root_dir", "-r", "--root_dir ROOT_DIR", "The top-level root folder where config files are located"
        cmd.option "source", "-s", "--source SOURCE", "Custom source directory"
        cmd.option "future", "--future", "Publishes posts with a future date"
        cmd.option "limit_posts", "--limit_posts MAX_POSTS", Integer,
                   "Limits the number of posts to parse and publish"
        cmd.option "watch", "-w", "--[no-]watch", "Watch for changes and rebuild"
        cmd.option "baseurl", "-b", "--baseurl URL",
                   "Serve the website from the given base URL"
        cmd.option "force_polling", "--force_polling", "Force watch to use polling"
        cmd.option "lsi", "--lsi", "Use LSI for improved related posts"
        cmd.option "show_drafts", "-D", "--drafts", "Render posts in the _drafts folder"
        cmd.option "unpublished", "--unpublished",
                   "Render posts that were marked as unpublished"
        cmd.option "disable_disk_cache", "--disable-disk-cache",
                   "Disable caching to disk in non-safe mode"
        cmd.option "quiet", "-q", "--quiet", "Silence output."
        cmd.option "verbose", "-V", "--verbose", "Print verbose output."
        cmd.option "incremental", "-I", "--incremental", "Enable incremental rebuild."
        cmd.option "strict_front_matter", "--strict_front_matter",
                   "Fail if errors are present in front matter"
      end
      # rubocop:enable Metrics/MethodLength

      # Run ::process method in a given set of Bridgetown::Command subclasses and suggest
      # re-running the associated command with --trace switch to obtain any additional
      # information or backtrace regarding the encountered Exception.
      #
      # cmd     - the Bridgetown::Command to be handled
      # options - configuration overrides
      # klass   - an array of Bridgetown::Command subclasses associated with the command
      #
      # Note that all exceptions are rescued..
      # rubocop: disable Lint/RescueException
      def process_with_graceful_fail(cmd, options, *klass)
        klass.each { |k| k.process(options) if k.respond_to?(:process) }
      rescue Exception => e
        raise e if cmd.trace

        msg = " Please append `--trace` to the `#{cmd.name}` command "
        dashes = "-" * msg.length
        Bridgetown.logger.error "", dashes
        Bridgetown.logger.error "Bridgetown #{Bridgetown::VERSION} ", msg
        Bridgetown.logger.error "", " for any additional information or backtrace. "
        Bridgetown.logger.abort_with "", dashes
      end
      # rubocop: enable Lint/RescueException
    end
  end
end
