# frozen_string_literal: true

module Bridgetown
  module Commands
    module Summarizable
      def summary(description = nil)
        return @desc.split("\n").last.strip unless description

        desc "Description:\n  #{description}"
      end
    end
  end
end
