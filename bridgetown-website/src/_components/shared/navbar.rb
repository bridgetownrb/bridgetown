# frozen_string_literal: true

module Shared
  class Navbar < Bridgetown::Component
    def initialize(metadata:, resource:, edge_version: false)
      @metadata = metadata
      @resource = resource
      @edge_version = edge_version
    end

    def docs_active
      "is-active" if @resource.relative_url.include?("/docs/")
    end

    def plugins_active
      "is-active" if @resource.relative_url == "/plugins/"
    end

    def news_active
      "is-active" if @resource.relative_url.include?("/blog/") || @resource.data.layout == "post"
    end

    def edge_class
      "edge-version" if @edge_version
    end
  end
end
