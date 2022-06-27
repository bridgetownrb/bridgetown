# frozen_string_literal: true

module Bridgetown
  module Commands
    class Apply < Thor::Group
      include Thor::Actions
      include Actions
      extend Summarizable

      Registrations.register do
        register(Apply, "apply", "apply", Apply.summary)
      end

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
        @logger = Bridgetown.logger

        if options[:apply]
          apply_after_new_command
        else
          apply_in_pwd
        end
      rescue SystemExit => e
        @logger.error "Problem occurred while running automation:"
        e.backtrace[0..3].each do |backtrace_line|
          @logger.info backtrace_line if backtrace_line.include?(":in `apply'")
        end
        raise e
      end

      protected

      def apply_after_new_command
        # Coming from the new command, so set up proper bundler env
        Bridgetown.with_unbundled_env do
          self.destination_root = New.created_site_dir
          inside(New.created_site_dir) do
            apply_from_url options[:apply]
          end
        end
      end

      def apply_in_pwd
        # Running standalone
        automation_command = args.empty? ? "bridgetown.automation.rb" : args[0]

        if args.empty? && !File.exist?("bridgetown.automation.rb")
          raise ArgumentError, "You must specify a path or a URL, " \
                               "or add bridgetown.automation.rb to the " \
                               "current folder."
        end

        Bridgetown.with_unbundled_env do
          apply_from_url automation_command
        end
      rescue ArgumentError => e
        @logger.warn "Oops!", e.message
      end
    end
  end
end
