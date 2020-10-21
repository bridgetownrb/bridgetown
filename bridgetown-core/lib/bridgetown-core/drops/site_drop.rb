# frozen_string_literal: true

module Bridgetown
  module Drops
    class SiteDrop < Drop
      extend Forwardable

      mutable false

      def_delegator  :@obj, :data
      def_delegators :@obj, :locale, :time, :pages, :static_files, :tags, :categories

      private def_delegator :@obj, :config, :fallback_data

      attr_writer :current_document

      def [](key)
        if key != "posts" && @obj.collections.key?(key)
          @obj.collections[key].docs
        else
          super(key)
        end
      end

      def key?(key)
        (key != "posts" && @obj.collections.key?(key)) || super
      end

      def posts
        @site_posts ||= @obj.posts.docs.sort { |a, b| b <=> a }
      end

      def html_pages
        @site_html_pages ||= @obj.pages.select do |page|
          page.html? || page.url.end_with?("/")
        end
      end

      def collections
        @site_collections ||= @obj.collections.values.sort_by(&:label).map(&:to_liquid)
      end

      # `Site#documents` cannot be memoized so that `Site#docs_to_write` can access the
      # latest state of the attribute.
      #
      # Since this method will be called after `Site#pre_render` hook, the `Site#documents`
      # array shouldn't thereafter change and can therefore be safely memoized to prevent
      # additional computation of `Site#documents`.
      def documents
        @documents ||= @obj.documents
      end

      def metadata
        @site_metadata ||= @obj.data["site_metadata"]
      end

      # return nil for `{{ site.config }}` even if --config was passed via CLI
      def config; end
    end
  end
end
