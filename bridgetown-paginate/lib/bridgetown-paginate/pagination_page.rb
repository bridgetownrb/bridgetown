# frozen_string_literal: true

module Bridgetown
  module Paginate
    #
    # This page handles the creation of the fake pagination pages based on the
    # original page configuration.
    # The code does the same things as the default Bridgetown page.rb code but
    # just forces the code to look into the template instead of the (currently
    # non-existing) pagination page. This page exists purely in memory and is
    # not read from disk
    #
    class PaginationPage < Bridgetown::GeneratedPage
      def initialize(page_to_copy, cur_page_nr, total_pages, index_pageandext, template_ext) # rubocop:disable Lint/MissingSuper
        @site = page_to_copy.site
        @base = ""
        @url = ""
        @name = index_pageandext.nil? ? "index#{template_ext}" : index_pageandext
        @path = page_to_copy.path
        @basename = File.basename(@path, ".*")
        @ext = File.extname(@name)

        # Only need to copy the data part of the page as it already contains the
        # layout information
        self.data = Bridgetown::Utils.deep_merge_hashes page_to_copy.data, {}
        self.content = page_to_copy.content

        # Store the current page and total page numbers in the pagination_info construct
        data["pagination_info"] = { "curr_page" => cur_page_nr, "total_pages" => total_pages }

        Bridgetown::Hooks.trigger :generated_pages, :post_init, self
      end

      # rubocop:disable Naming/AccessorMethodName
      def set_url(url_value)
        @path = url_value.delete_prefix "/"
        @dir = @path.ends_with?("/") ? @path : File.dirname(@path)
        @url = url_value
      end
      # rubocop:enable Naming/AccessorMethodName

      def destination(dest)
        path = site.in_dest_dir(
          dest, URL.unescape_path(url).delete_prefix(site.base_path(strip_slash_only: true))
        )
        path = File.join(path, "index") if url.end_with?("/")
        path << output_ext unless path.end_with? output_ext
        path
      end
    end
  end
end
