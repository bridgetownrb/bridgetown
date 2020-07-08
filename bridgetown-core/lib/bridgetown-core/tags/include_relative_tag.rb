# frozen_string_literal: true

# Due to IncludeTag being in same namespace, this must be here for Zeitwerk
require_relative "include_tag"

module Bridgetown
  module Tags
    class IncludeRelativeTag < IncludeTag
      def tag_includes_dirs(context)
        Array(page_path(context)).freeze
      end

      def page_path(context)
        if context.registers[:page].nil?
          context.registers[:site].source
        else
          site = context.registers[:site]
          page_payload = context.registers[:page]
          resource_path = \
            if page_payload["collection"].nil?
              page_payload["path"]
            else
              File.join(site.config["collections_dir"], page_payload["path"])
            end
          # rubocop:disable Performance/DeleteSuffix
          resource_path.sub!(%r!/#excerpt\z!, "")
          # rubocop:enable Performance/DeleteSuffix
          site.in_source_dir File.dirname(resource_path)
        end
      end
    end
  end
end

Liquid::Template.register_tag("include_relative", Bridgetown::Tags::IncludeRelativeTag)
