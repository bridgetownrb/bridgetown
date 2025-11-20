# frozen_string_literal: true

require_relative "../commands/concerns/actions"

module Bridgetown
  module Commands2
    class Apply < Samovar::Command
      include Freyia::Setup
      include Commands::Actions

      Registrations.register Apply, "apply"

      self.description = "Applies an automation to the current site"

      one :path_or_url, "Either a path or a URL to an automation file or Git repo"

      def call(from_new_command: false, created_site_dir: nil)
        self.source_paths = [Dir.pwd]
        @logger = Bridgetown.logger

        if from_new_command
          apply_after_new_command(created_site_dir)
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

      def apply_after_new_command(created_site_dir)
        # Coming from the new command, so set up proper bundler env
        Bridgetown.with_unbundled_env do
          self.destination_root = created_site_dir
          inside(created_site_dir) do
            apply_from_url path_or_url
          end
        end
      end

      def apply_in_pwd
        # Running standalone
        self.destination_root = Dir.pwd
        automation_command = path_or_url.nil? ? "bridgetown.automation.rb" : path_or_url

        if path_or_url.nil? && !File.exist?("bridgetown.automation.rb")
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
