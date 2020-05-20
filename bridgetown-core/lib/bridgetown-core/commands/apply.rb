# frozen_string_literal: true

require "erb"

module Bridgetown
  module Commands
    class Apply < Thor::Group
      include Thor::Actions

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

      def apply_automation
        if options[:apply]
          self.destination_root = New.created_site_dir
          apply(transform_automation_url(options[:apply]))
        else
          raise ArgumentError, "You must specify a path or a URL" if args.empty?

          apply(transform_automation_url(args[0]))
        end
      end

      protected

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
