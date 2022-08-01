# frozen_string_literal: true

module Bridgetown
  module Model
    class PluginOrigin < RepoOrigin
      class << self
        def handle_scheme?(scheme)
          scheme == "plugin"
        end
      end

      def manifest
        @manifest ||= begin
          manifest_origin = Addressable::URI.unescape(url.path.delete_prefix("/")).split("/").first
          site.config.source_manifests.find do |manifest|
            manifest.origin.to_s == manifest_origin
          end.tap do |manifest|
            raise "Unable to locate a source manifest for #{manifest_origin}" unless manifest
          end
        end
      end

      def relative_path
        @relative_path ||= Pathname.new(
          Addressable::URI.unescape(url.path.delete_prefix("/")).split("/")[1..].join("/")
        )
      end

      def original_path
        @original_path ||= relative_path.expand_path(manifest.content)
      end
    end
  end
end
