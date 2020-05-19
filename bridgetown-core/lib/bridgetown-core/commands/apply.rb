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

      summary "Applies a starter kit to the current site"

      def self.source_root
        Dir.pwd
      end

      def apply_starter_kit
        if options[:apply]
          self.destination_root = New.created_site_dir
          apply(options[:apply])
        else
          raise ArgumentError, "You must specify a path or a URL" if args.empty?

          apply(args[0])
        end
      end
    end
  end
end
