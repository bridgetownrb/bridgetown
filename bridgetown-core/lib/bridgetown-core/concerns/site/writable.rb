# frozen_string_literal: true

module Bridgetown
  module Site::Writable
    # Remove orphaned files and empty directories in destination.
    #
    # @return [void]
    def cleanup
      @cleaner.cleanup!
    end

    # Write static files, pages, and posts.
    #
    # @return [void]
    def write
      each_site_file do |item|
        item.write(dest) if regenerator.regenerate?(item)
      end
      regenerator.write_metadata
      Bridgetown::Hooks.trigger :site, :post_write, self
    end

    # Yields the pages from {#pages}, {#static_files_to_write}, and
    # {#docs_to_write}.
    #
    # @yieldparam item [Document, Page, StaticFile] Yields a
    # {#Bridgetown::Page}, {#Bridgetown::StaticFile}, or
    # {#Bridgetown::Document} object.
    #
    # @return [void]
    #
    # @see #pages
    # @see #static_files_to_write
    # @see #docs_to_write
    # @see Page
    # @see StaticFile
    # @see Document
    def each_site_file
      %w(pages static_files_to_write docs_to_write).each do |type|
        send(type).each do |item|
          yield item
        end
      end
    end
  end
end
