module Shared
  class Head < Bridgetown::Component
    include Liquid::StandardFilters

    attr_reader :metadata

    def initialize(title:, metadata:)
      @title = title || ""
      @metadata = metadata
    end

    def page_title
      strip_html(strip_newlines(@title)).html_safe
    end
  end
end
