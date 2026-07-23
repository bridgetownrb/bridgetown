# frozen_string_literal: true

module Bridgetown
  module Routines
    class SiteWatcher
      def initialize(site:)
        @site = site
      end

      def execute(instance)
        instance.ready!
        Bridgetown.logger.set_prefix("Watcher", color: :magenta)
        Bridgetown::Watcher.watch(@site)
      end

      def name  = "Bridgetown Site Watcher"
      def key   = :site_watcher
    end
  end
end
