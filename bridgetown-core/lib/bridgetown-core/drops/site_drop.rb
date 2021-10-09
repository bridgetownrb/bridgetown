# frozen_string_literal: true

module Bridgetown
  module Drops
    class SiteDrop < Drop
      extend Forwardable

      mutable false

      def_delegators :@obj,
                     :baseurl, # deprecated
                     :base_path,
                     :data,
                     :locale,
                     :time,
                     :pages,
                     :generated_pages,
                     :static_files,
                     :tags,
                     :categories,
                     :taxonomies,
                     :taxonomy_types

      private def_delegator :@obj, :config, :fallback_data

      attr_writer :current_document

      def [](key)
        if !@obj.uses_resource? && !%w(posts data).freeze.include?(key) &&
            @obj.collections.key?(key)
          return @obj.collections[key].docs
        end

        super(key)
      end

      def key?(key)
        (!@obj.uses_resource? && key != "posts" && @obj.collections.key?(key)) || super
      end

      def uses_resource
        @obj.uses_resource?
      end

      def resources
        @resources ||= @obj.resources
      end

      def contents
        @contents ||= @obj.contents
      end

      def metadata
        @site_metadata ||= @obj.data["site_metadata"]
      end

      # TODO: change this so you *do* use site.config...aka site.config.timezone,
      # not site.timezone
      #
      # return nil for `{{ site.config }}` even if --config was passed via CLI
      def config; end
    end
  end
end
