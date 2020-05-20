# frozen_string_literal: true

require "erb"

module Bridgetown
  module Commands
    class Apply < Thor::Group
      include Thor::Actions
      include Actions

      Registrations.register do
        register(Apply, "apply", "apply", Apply.summary)
      end

      extend Summarizable

      def self.banner
        "bridgetown apply PATH or URL"
      end

      summary "Applies an automation to the current site"

      def self.source_root
        Dir.pwd
      end

      def self.exit_on_failure?
        true
      end

      def apply_automation
        @source_paths = [Dir.pwd]

        if options[:apply]
          apply_after_new_command
        else
          apply_in_pwd
        end
      rescue SystemExit => e
        Bridgetown.logger.error "Problem occurred while running automation:"
        e.backtrace[0..3].each do |backtrace_line|
          Bridgetown.logger.info backtrace_line if backtrace_line.include?(":in `apply'")
        end
        raise e
      end

      protected

      def apply_after_new_command
        # Coming from the new command, so set up proper bundler env
        Bundler.with_clean_env do
          self.destination_root = New.created_site_dir
          inside(New.created_site_dir) do
            apply(transform_automation_url(options[:apply]))
          end
        end
      end

      def apply_in_pwd
        # Running standalone
        automation_command = args.empty? ? "bridgetown.automation.rb" : args[0]

        if args.empty? && !File.exist?("bridgetown.automation.rb")
          raise ArgumentError, "You must specify a path or a URL," \
                               " or add bridgetown.automation.rb to the" \
                               " current folder."
        end

        apply(transform_automation_url(automation_command))
      rescue ArgumentError => e
        Bridgetown.logger.warn "Oops!", e.message
      end

      def transform_automation_url(arg)
        if arg.start_with?("https://gist.github.com")
          return arg.sub("https://gist.github.com", "https://gist.githubusercontent.com") + "/raw/bridgetown.automation.rb"
        elsif arg.start_with?("https://github.com")
          return arg.sub("https://github.com", "https://raw.githubusercontent.com") + "/master/bridgetown.automation.rb"
        end

        arg
      end
    end
  end
end
