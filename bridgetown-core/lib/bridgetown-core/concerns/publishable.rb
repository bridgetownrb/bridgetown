# frozen_string_literal: true

module Bridgetown
  module Publishable
    # Whether the resource is published or not, as indicated in YAML front-matter
    #
    # @return [Boolean]
    def published?
      !(data.key?("published") && data["published"] == false)
    end

    def publishable?
      return true if collection.data?
      return false unless published? || @site.config.unpublished

      future_allowed = collection.metadata.future || @site.config.future
      future_allowed || date <= @site.time
    end
  end
end
