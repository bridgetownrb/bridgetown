# frozen_string_literal: true

module Bridgetown
  module Site::Writable
    # Write static files, pages, and posts.
    #
    # Returns nothing.
    def write
      each_site_file do |item|
        item.write(dest) if regenerator.regenerate?(item)
      end
      regenerator.write_metadata
      Bridgetown::Hooks.trigger :site, :post_write, self
    end

    def each_site_file
      %w(pages static_files docs_to_write).each do |type|
        send(type).each do |item|
          yield item
        end
      end
    end
  end
end
