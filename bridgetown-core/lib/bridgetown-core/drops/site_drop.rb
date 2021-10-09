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

      def config
        @obj.config
      end
    end
  end
end
