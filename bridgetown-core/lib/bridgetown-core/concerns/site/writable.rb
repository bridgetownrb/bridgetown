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
      each_site_file { |item| item.write(dest) }
      write_redirecting_index if config.prefix_default_locale

      Bridgetown::Hooks.trigger :site, :post_write, self
    end

    # Yields all content objects while looping through {#generated_pages},
    #   {#static_files_to_write}, {#resources_to_write}.
    #
    # @yieldparam item [Bridgetown::Resource::Base, GeneratedPage, StaticFile]
    #
    # @return [void]
    def each_site_file
      %w(generated_pages static_files_to_write resources_to_write).each do |type|
        send(type).each do |item| # rubocop:disable Style/ExplicitBlockArgument
          yield item
        end
      end
    end

    def resources_cache_manifest
      resources.each_with_object({}) do |resource, hsh|
        next if resource.relative_url == ""

        hsh[resource.relative_url] = {
          id: resource.model.id,
        }
      end
    end

    def write_redirecting_index
      resource = resources.find do |item|
        item.data.slug == "index" && item.data.locale == config.default_locale
      end

      unless resource
        Bridgetown.logger.warn(
          "Index file not found in the source folder, cannot generate top-level redirect file"
        )
        return
      end

      index_html = <<~HTML # rubocop:disable Bridgetown/HTMLEscapedHeredoc
        <!DOCTYPE html>
        <html>
          <head>
            <title>Redirecting…</title>
            <meta http-equiv="refresh" content="0; url=#{resource.relative_url}" />
          </head>
          <body></body>
        </html>
      HTML

      File.write(in_dest_dir("index.html"), index_html, mode: "wb")
    end
  end
end
