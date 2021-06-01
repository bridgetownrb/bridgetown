# frozen_string_literal: true

module Bridgetown
  # TODO: to be retired once the Resource engine is made official
  class PageReader
    attr_reader :site, :dir, :unfiltered_content

    def initialize(site, dir)
      @site = site
      @dir = dir
      @unfiltered_content = []
    end

    # Create a new `Bridgetown::Page` object for each entry in a given array.
    #
    # files - An array of file names inside `@dir`
    #
    # Returns an array of publishable `Bridgetown::Page` objects.
    def read(files)
      files.each do |page|
        @unfiltered_content << Page.new(@site, @site.source, @dir, page)
      end
      @unfiltered_content.select { |page| site.publisher.publish?(page) }
    end
  end
end
