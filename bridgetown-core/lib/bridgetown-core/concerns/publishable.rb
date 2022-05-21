# frozen_string_literal: true

module Bridgetown
  module Publishable
    # Whether the resource is published or not, as indicated in YAML front-matter
    def published?
      !(data.key?("published") && data["published"] == false)
    end

    def publishable?
      return true if collection.data?
      return false unless published? || @site.config.unpublished

      future_allowed = collection.metadata.future || @site.config.future
      this_time = date.is_a?(Date) ? date.to_time.to_i : date.to_i

      future_allowed || this_time <= @site.time.to_i
    end
  end
end
