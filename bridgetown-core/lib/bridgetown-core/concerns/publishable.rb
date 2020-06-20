# frozen_string_literal: true

module Bridgetown
  module Publishable
    # Whether the file is published or not, as indicated in YAML front-matter
    def published?
      !(data.key?("published") && data["published"] == false)
    end
  end
end
