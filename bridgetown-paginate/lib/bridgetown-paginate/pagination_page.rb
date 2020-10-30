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
    class PaginationPage < Bridgetown::Page
      # rubocop:todo Metrics/AbcSize
      def initialize(page_to_copy, cur_page_nr, total_pages, index_pageandext, template_ext)
        @site = page_to_copy.site
        @base = ""
        @url = ""
        @name = index_pageandext.nil? ? "index#{template_ext}" : index_pageandext
        @path = page_to_copy.path

        # Creates the basename and ext member values
        process(@name)

        # Only need to copy the data part of the page as it already contains the
        # layout information
        self.data = Bridgetown::Utils.deep_merge_hashes page_to_copy.data, {}
        if !page_to_copy.data["autopage"]
          self.content = page_to_copy.content
        elsif page_to_copy.data["autopage"].key?("display_name")
          # If the page is an auto page then migrate the necessary autopage info
          # across into the new pagination page (so that users can get the
          # correct keys etc)
          data["autopages"] = Bridgetown::Utils.deep_merge_hashes(
            page_to_copy.data["autopage"], {}
          )
        end

        # Store the current page and total page numbers in the pagination_info construct
        data["pagination_info"] = { "curr_page" => cur_page_nr, "total_pages" => total_pages }

        # Perform some validation that is also performed in Bridgetown::Page
        validate_data! page_to_copy.path
        validate_permalink! page_to_copy.path

        Bridgetown::Hooks.trigger :pages, :post_init, self
      end
      # rubocop:enable Metrics/AbcSize

      # rubocop:disable Naming/AccessorMethodName
      def set_url(url_value)
        @path = url_value.delete_prefix "/"
        @dir  = File.dirname(@path)
        @url = url_value
      end
      # rubocop:enable Naming/AccessorMethodName
    end
  end
end
