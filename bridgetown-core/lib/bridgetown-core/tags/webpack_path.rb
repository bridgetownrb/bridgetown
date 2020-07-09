# frozen_string_literal: true

module Bridgetown
  module Tags
    # A helper class to help find the path to webpack asset inside of a webpack
    # manifest file.
    class WebpackPath < Liquid::Tag
      include Bridgetown::Filters::URLFilters

      # @param tag_name [String] Name of the tag
      # @param asset_type [String] The type of asset to parse (js, css)
      # @param options [Hash] An options hash
      # @return WebpackPath
      # @see {https://www.rdoc.info/github/Shopify/liquid/Liquid/Tag#initialize-instance_method}
      def initialize(tag_name, asset_type, options)
        super

        # js or css
        @asset_type = asset_type.strip
      end

      # Render the contents of a webpack manifest file
      # @param context [String] Root directory that contains the manifest file
      #
      # @return [String] Returns "MISSING_WEBPACK_MANIFEST" if the manifest
      # file isnt found
      # @return [nil] Returns nil if the asset isnt found
      # @return [String] Returns the path to the asset if no issues parsing
      #
      # @raise [WebpackAssetError] if unable to find css or js in the manifest
      # file
      def render(context)
        @context = context
        site = context.registers[:site]

        manifest_file = site.in_root_dir(".bridgetown-webpack", "manifest.json")

        parse_manifest_file(manifest_file)
      end

      private

      def parse_manifest_file(manifest_file)
        return "MISSING_WEBPACK_MANIFEST" unless File.exist?(manifest_file)

        manifest = JSON.parse(File.read(manifest_file))
        frontend_path = relative_url("_bridgetown/static")

        known_assets = %w(js css)

        if known_assets.include?(@asset_type)
          asset_path = manifest["main.#{@asset_type}"]

          raise_webpack_asset_error(@asset_type) if asset_path.nil?

          asset_path = asset_path.split("/").last
          return [frontend_path, @asset_type, asset_path].join("/")
        end

        Bridgetown.logger.error("Unknown Webpack asset type", @asset_type)
        nil
      end

      def raise_webpack_asset_error(asset_type)
        stack_trace = caller.join("\n")
        error_message = "
          There was an error parsing your #{asset_type} files.
          Please check your #{asset_type} for any errors.\n\n"

        error = Errors::WebpackAssetError.new(error_message)

        Bridgetown.logger.abort_with(error.class) do
          Bridgetown.logger.info(error.message)
          Bridgetown.logger.info(stack_trace + "\n\n")
          error.message
        end

        # Bridgetown.logger.abort_with(Errors::WebpackAssetError) do
        #   Bridgetown.logger.warn(error_message)
        #   Bridgetown.logger.info(stack_trace)
        #   Bridgetown.logger.error(error_message)
        # end
      end
    end
  end
end

Liquid::Template.register_tag("webpack_path", Bridgetown::Tags::WebpackPath)
