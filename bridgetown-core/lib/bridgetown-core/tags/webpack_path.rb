# frozen_string_literal: true

module Bridgetown
  module Tags
    # A helper class to help find the path to webpack asset inside of a webpack
    # manifest file.
    class WebpackPath < Liquid::Tag
      # @param tag_name [String] Name of the tag
      # @param asset_type [String] The type of asset to parse (js, css)
      # @param options [Hash] An options hash
      # @return [void]
      # @see {https://www.rdoc.info/github/Shopify/liquid/Liquid/Tag#initialize-instance_method}
      def initialize(tag_name, asset_type, options)
        super

        # js or css
        @asset_type = asset_type.strip
      end

      # Render an asset path based on the Webpack manifest file
      # @param context [Liquid::Context] Context passed to the tag
      #
      # @return [String] Returns "MISSING_WEBPACK_MANIFEST" if the manifest
      # file isn't found
      # @return [String] Returns a blank string if the asset isn't found
      # @return [String] Returns the path to the asset if no issues parsing
      #
      # @raise [WebpackAssetError] if unable to find css or js in the manifest
      # file
      def render(context)
        @context = context
        site = context.registers[:site]
        Bridgetown::Utils.parse_webpack_manifest_file(site, @asset_type) || ""
      end
    end
  end
end

Liquid::Template.register_tag("webpack_path", Bridgetown::Tags::WebpackPath)
