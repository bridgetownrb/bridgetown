# frozen_string_literal: true

module Bridgetown
  module Tags
    class WebpackPath < Liquid::Tag
      include Bridgetown::Filters::URLFilters

      def initialize(tag_name, asset_type, tokens)
        super

        # js or css
        @asset_type = asset_type.strip
      end

      def render(context)
        @context = context
        site = context.registers[:site]

        frontend_path = relative_url("_bridgetown/static")

        manifest_file = site.in_root_dir(".bridgetown-webpack", "manifest.json")
        if File.exist?(manifest_file)
          manifest = JSON.parse(File.read(manifest_file))
          if @asset_type == "js"
            js_path = manifest["main.js"].split("/").last
            [frontend_path, "js", js_path].join("/")
          elsif @asset_type == "css"
            css_path = manifest["main.css"].split("/").last
            [frontend_path, "css", css_path].join("/")
          else
            Bridgetown.logger.error("Unknown Webpack asset type", @asset_type)
            nil
          end
        else
          "MISSING_WEBPACK_MANIFEST"
        end
      end
    end
  end
end

Liquid::Template.register_tag("webpack_path", Bridgetown::Tags::WebpackPath)
