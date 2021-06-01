module Shared
  class Navbar < Bridgetown::Component
    def initialize(metadata:, resource:, version:)
      @metadata = metadata
      @resource = resource
      @version = version
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

    def beta_class
      "beta" if @version.include?("beta")
    end
  end
end