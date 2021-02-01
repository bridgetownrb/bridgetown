# frozen_string_literal: true

class Bridgetown::Site
  module Writable
    # Remove orphaned files and empty directories in destination.
    #
    # @return [void]
    def cleanup
      @cleaner.cleanup!
    end

    # Write static files, pages, and documents to the destination folder.
    #
    # @return [void]
    def write
      each_site_file do |item|
        item.write(dest) if regenerator.regenerate?(item)
      end
      regenerator.write_metadata
      Bridgetown::Hooks.trigger :site, :post_write, self
    end

    # Yields all content objects while looping through {#pages},
    #   {#static_files_to_write}, and {#docs_to_write}.
    #
    # @yieldparam item [Document, Page, StaticFile]
    #
    # @return [void]
    def each_site_file
      %w(pages static_files_to_write docs_to_write resources_to_write).each do |type|
        send(type).each do |item|
          yield item
        end
      end
    end

    def resources_cache_manifest
      resources.each_with_object({}) do |resource, hsh|
        next if resource.relative_url == ""

        hsh[resource.relative_url] = {
          collection: resource.origin.collection.label,
          origin_klass: resource.origin.class.name,
          relative_path: resource.origin.relative_path.to_s,
        }
      end
    end
  end
end
