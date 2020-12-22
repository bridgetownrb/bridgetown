# frozen_string_literal: true

module Bridgetown
  # A Bridgetown::Page subclass to handle processing files without reading it to
  # determine the page-data and page-content based on Front Matter delimiters.
  #
  # The class instance is basically just a bare-bones entity with just
  # attributes "dir", "name", "path", "url" defined on it.
  class PageWithoutAFile < Page
    Bridgetown.logger.warn "NOTICE: the PageWithoutAFile class is deprecated and" \
                           " will be removed in Bridgetown 0.20."

    def read_yaml(*)
      @data ||= {}
    end
  end
end
