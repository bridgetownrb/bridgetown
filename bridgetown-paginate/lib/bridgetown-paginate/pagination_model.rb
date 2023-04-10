# frozen_string_literal: true

module Bridgetown
  module Paginate
    #
    # The main model for the pagination, handles the orchestration of the
    # pagination and calling all the necessary bits and bobs needed :)
    #
    class PaginationModel
      @debug = false # is debug output enabled?
      # The lambda to use for logging
      @logging_lambda = nil
      # The lambda used to create pages and add them to the site
      @page_add_lambda = nil
      # Lambda to remove a page
      @page_remove_lambda = nil
      # Lambda to get all documents/posts in a particular collection (by name)
      @collection_by_name_lambda = nil

      def initialize(
        logging_lambda,
        page_add_lambda,
        page_remove_lambda,
        collection_by_name_lambda
      )
        @logging_lambda = logging_lambda
        @page_add_lambda = page_add_lambda
        @page_remove_lambda = page_remove_lambda
        @collection_by_name_lambda = collection_by_name_lambda
      end

      # rubocop:disable Metrics/BlockLength
      def run(default_config, templates, site_title) # rubocop:todo Metrics/AbcSize
        if templates.size.to_i <= 0
          @logging_lambda.call(
            "is enabled in the config, but no paginated pages found. " \
            "Add 'pagination:\\n  collection: <label>' to the front-matter of a page.",
            "warn"
          )
          return
        end

        @docs_by_collection_cache = {}

        # Now for each template page generate the paginator for it
        templates.each do |template|
          # All pages that should be paginated need to include the pagination
          # config element
          unless template.data["pagination"].is_a?(Hash) || template.data["paginate"].is_a?(Hash)
            next
          end

          template_config = Bridgetown::Utils.deep_merge_hashes(
            default_config,
            template.data["pagination"] || template.data["paginate"] || {}
          ).tap do |config|
            config["collection"] = config["collection"].to_s if config["collection"].is_a?(Symbol)
            config["category"] = config["category"].to_s if config["category"].is_a?(Symbol)
            config["tag"] = config["tag"].to_s if config["tag"].is_a?(Symbol)
            config["locale"] = config["locale"].to_s if config["locale"].is_a?(Symbol)
          end

          # Is debugging enabled on the page level
          @debug = template_config["debug"]
          _debug_print_config_info(template_config, template.path)

          next unless template_config["enabled"]

          if template.site.config.available_locales.size > 1 && !template_config["locale"]
            template_config["locale"] =
              template.data["locale"].to_s
          end

          @logging_lambda.call "found page: #{template.path}", "debug" unless @debug

          # Request all documents in all collections that the user has requested
          all_posts = get_docs_in_collections(template_config["collection"], template)

          # Create the necessary indexes for the posts
          all_categories = if template_config["category"]
                             PaginationIndexer.index_documents_by(all_posts, "categories")
                           end
          all_tags = if template_config["tag"]
                       PaginationIndexer.index_documents_by(all_posts, "tags")
                     end
          all_locales = if template_config["locale"]
                          PaginationIndexer.index_documents_by(all_posts, "locale")
                        end

          # Load in custom query index, if specified
          all_where_matches = if template_config["where_query"]
                                PaginationIndexer.index_documents_by(
                                  all_posts, template_config["where_query"]
                                )
                              end

          documents_payload = {
            posts: all_posts,
            tags: all_tags,
            categories: all_categories,
            locales: all_locales,
            where_matches: all_where_matches,
          }

          # TODO: NOTE!!! This whole request for posts and indexing results
          # could be cached to improve performance, leaving like this for
          # now during testing

          # Now construct the pagination data for this template page
          paginate(
            template,
            template_config,
            site_title,
            documents_payload
          )
        end

        # Return the total number of templates found
        templates.size.to_i
      end
      # rubocop:enable Metrics/BlockLength

      # Returns the combination of all documents in the collections that are
      # specified
      # raw_collection_names can either be a list of collections separated by a
      # ',' or ' ' or a single string
      def get_docs_in_collections(raw_collection_names, template)
        if raw_collection_names.blank?
          @logging_lambda.call "Missing collection name for paginated page: " \
                               "#{template.relative_path}"
          return []
        end

        if @docs_by_collection_cache[raw_collection_names]
          return @docs_by_collection_cache[raw_collection_names]
        end

        collection_names = if raw_collection_names.is_a?(String)
                             raw_collection_names.split %r!/;|,|\s/!
                           else
                             raw_collection_names
                           end

        docs = []
        # Now for each of the collections get the docs
        collection_names.each do |coll_name|
          # Request all the documents for the collection in question, and join
          # it with the total collection
          docs += @collection_by_name_lambda.call coll_name.downcase.strip
        end

        # Hidden documents should not not be processed anywhere.
        docs = docs.reject { |doc| doc.data.exclude_from_pagination }

        @docs_by_collection_cache[raw_collection_names] = docs

        docs
      end

      # rubocop:disable Layout/LineLength
      def _debug_print_config_info(config, page_path) # rubocop:todo Metrics/AbcSize
        r = 20
        f = "Pagination: ".rjust(20)
        # Debug print the config
        return unless @debug

        puts "#{f}----------------------------"
        puts "#{f}Page: #{page_path}"
        puts "#{f} Active configuration"
        puts f + "  Enabled: ".ljust(r) + config["enabled"].to_s
        puts f + "  Items per page: ".ljust(r) + config["per_page"].to_s
        puts f + "  Permalink: ".ljust(r) + config["permalink"].to_s
        puts f + "  Title: ".ljust(r) + config["title"].to_s
        puts f + "  Limit: ".ljust(r) + config["limit"].to_s
        puts f + "  Sort by: ".ljust(r) + config["sort_field"].to_s
        puts f + "  Sort reverse: ".ljust(r) + config["sort_reverse"].to_s

        puts "#{f} Active Filters"
        puts f + "  Collection: ".ljust(r) + config["collection"].to_s
        puts f + "  Offset: ".ljust(r) + config["offset"].to_s
        puts f + "  Category: ".ljust(r) + (config["category"].nil? || config["category"] == "posts" ? "[Not set]" : config["category"].to_s)
        puts f + "  Tag: ".ljust(r) + (config["tag"].nil? ? "[Not set]" : config["tag"].to_s)
        puts f + "  Locale: ".ljust(r) + (config["locale"].nil? ? "[Not set]" : config["locale"].to_s)
      end
      # rubocop:enable Layout/LineLength

      # rubocop:disable Layout/LineLength
      def _debug_print_filtering_info(filter_name, before_count, after_count)
        # Debug print the config
        return unless @debug

        puts "#{"Pagination: ".rjust(20)} Filtering by: #{filter_name.to_s.ljust(9)} #{before_count.to_s.rjust(3)} => #{after_count}"
      end
      # rubocop:enable Layout/LineLength

      # Paginates the blog's posts. Renders the index.html file into paginated
      # directories, e.g.: page2/index.html, page3/index.html, etc and adds more
      # site-wide data.
      #
      # site - The Site.
      # template - The index.html Page that requires pagination.
      # config - The configuration settings that should be used
      #
      # rubocop:todo Metrics/AbcSize
      def paginate(template, config, site_title, documents_payload)
        # By default paginate on all posts in the site
        using_posts = documents_payload[:posts]

        # Now start filtering out any posts that the user doesn't want included
        # in the pagination

        if config["category"]
          before = using_posts.size.to_i
          using_posts = PaginationIndexer.read_config_value_and_filter_documents(
            config,
            "category",
            using_posts,
            documents_payload[:categories]
          )
          _debug_print_filtering_info("Category", before, using_posts.size.to_i)
        end

        if config["tag"]
          before = using_posts.size.to_i
          using_posts = PaginationIndexer.read_config_value_and_filter_documents(
            config,
            "tag",
            using_posts,
            documents_payload[:tags]
          )
          _debug_print_filtering_info("Tag", before, using_posts.size.to_i)
        end

        if config["locale"]
          before = using_posts.size.to_i
          using_posts = PaginationIndexer.read_config_value_and_filter_documents(
            config,
            "locale",
            using_posts,
            documents_payload[:locales]
          )
          _debug_print_filtering_info("Locale", before, using_posts.size.to_i)
        end

        if config["where_query"]
          before = using_posts.size.to_i
          using_posts = PaginationIndexer.read_config_value_and_filter_documents(
            config,
            "where_query",
            using_posts,
            documents_payload[:where_matches]
          )
          _debug_print_filtering_info(
            "Where Query (#{config["where_query"]})",
            before,
            using_posts.size.to_i
          )
        end

        # Apply sorting to the posts if configured, any field for the post is
        # available for sorting
        if config["sort_field"]
          sort_field = config["sort_field"].to_s

          # There is an issue in Bridgetown related to lazy initialized member
          # variables that causes iterators to
          # break when accessing an uninitialized value during iteration. This
          # happens for document.rb when the <=> comparison function
          # is called (as this function calls the 'date' field which for drafts
          # are not initialized.)
          # So to unblock this common issue for the date field I simply iterate
          # once over every document and initialize the .date field explicitly
          if @debug
            puts "#{"Pagination: ".rjust(20)}Rolling through the date fields for all documents"
          end
          using_posts.each do |u_post|
            next unless u_post.respond_to?(:date)

            tmp_date = u_post.date
            next unless !tmp_date || tmp_date.nil?

            if @debug
              puts "Pagination: ".rjust(20) +
                "Explicitly assigning date for doc: #{u_post.data["title"]} | #{u_post.path}"
            end
            u_post.date = File.mtime(u_post.path)
          end

          using_posts.sort! do |a, b|
            Utils.sort_values(
              Utils.sort_get_post_data(a.data, sort_field),
              Utils.sort_get_post_data(b.data, sort_field)
            )
          end

          # Remove the first x entries
          offset_post_count = [0, config["offset"].to_i].max
          using_posts.pop(offset_post_count)

          using_posts.reverse! if config["sort_reverse"]
        end

        # Calculate the max number of pagination-pages based on the configured per page value
        total_pages = Utils.calculate_number_of_pages(using_posts, config["per_page"])

        # If a upper limit is set on the number of total pagination pages then impose that now
        if config["limit"].to_i.positive? && config["limit"].to_i < total_pages
          total_pages = config["limit"].to_i
        end

        #### BEFORE STARTING REMOVE THE TEMPLATE PAGE FROM THE SITE LIST!
        @page_remove_lambda.call template

        # list of all newly created pages
        newpages = []

        # Consider the index page name and extension
        # By default, they will be nil and the Page object will infer
        # it from the template used
        index_page_name = config["indexpage"].split(".")[0] unless config["indexpage"].nil?
        index_page_ext = unless index_page_name.nil? || config["extension"].nil?
                           Utils.ensure_leading_dot(config["extension"])
                         end
        index_page_with_ext = index_page_name + index_page_ext if index_page_name

        # In case there are no (visible) posts, generate the index file anyway
        total_pages = 1 if total_pages.zero?

        # Now for each pagination page create it and configure the ranges for
        # the collection
        # The .paginator member is a built in thing in Bridgetown and references the
        # paginator implementation
        # rubocop:disable Metrics/BlockLength
        (1..total_pages).each do |cur_page_nr|
          # 1. Create the in-memory page
          # External Proc call to create the actual page for us (this is
          # passed in when the pagination is run)
          newpage = PaginationPage.new(
            template,
            cur_page_nr,
            total_pages,
            index_page_with_ext,
            template.extname
          )

          # 2. Create the url for the in-memory page (calc permalink etc),
          # construct the title, set all page.data values needed
          paginated_page_url = config["permalink"]
          first_index_page_url = if template.data["permalink"]
                                   template.data["permalink"]
                                 elsif template.respond_to?(:relative_url)
                                   template.relative_url
                                 else
                                   template.dir
                                 end
          first_index_page_url = Utils.ensure_trailing_slash(
            Utils.remove_double_slash(first_index_page_url)
          )
          paginated_page_url = File.join(first_index_page_url, paginated_page_url)

          # 3. Create the paginator logic for this page, pass in the prev and next
          # page numbers, assign paginator to in-memory page
          newpage.paginator = Paginator.new(
            config["per_page"],
            first_index_page_url,
            paginated_page_url,
            using_posts,
            cur_page_nr,
            total_pages,
            index_page_name,
            index_page_ext
          )

          newpage.set_url(newpage.paginator.page_path)
          newpage.data["permalink"] = newpage.paginator.page_path if template.data["permalink"]

          # Transfer the title across to the new page
          tmp_title = template.data["title"] || site_title

          # If the user specified a title suffix to be added then let's add that
          # to all the pages except the first
          if cur_page_nr > 1 && config.key?("title")
            newtitle = Utils.format_page_title(
              config["title"],
              tmp_title,
              cur_page_nr,
              total_pages
            )
            newpage.data["title"] = newtitle.to_s
          else
            newpage.data["title"] = tmp_title
          end

          # Signals that this page is automatically generated by the pagination logic
          newpage.data["autogen"] = "bridgetown-paginate"

          # If there's only one post (like on a per_page: 1 scenario), let's be
          # helpful and supply a document variable
          newpage.data["document"] = using_posts.first if using_posts.size == 1

          # Add the page to the site
          @page_add_lambda.call newpage

          # Store the page in an internal list for later referencing if we need
          # to generate a pagination number path later on
          newpages << newpage
        end
        # rubocop:enable Metrics/BlockLength

        # Now generate the pagination number path, e.g. so that the users can
        # have a prev 1 2 3 4 5 next structure on their page
        # simplest is to include all of the links to the pages preceeding the
        # current one (e.g for page 1 you get the list 2, 3, 4.... and for
        # page 2 you get the list 3,4,5...)
        return unless config["trail"] && !config["trail"].nil? && newpages.size.to_i.positive?

        trail_before = [config["trail"]["before"].to_i, 0].max
        trail_after = [config["trail"]["after"].to_i, 0].max
        trail_length = trail_before + trail_after + 1

        return unless trail_before.positive? || trail_after.positive?

        newpages.select do |npage|
          # Selecting the beginning of the trail
          idx_start = [npage.paginator.page - trail_before - 1, 0].max
          # Selecting the end of the trail
          idx_end = [idx_start + trail_length, newpages.size.to_i].min

          # Always attempt to maintain the max total of <trail_length> pages
          # in the trail (it will look better if the trail doesn't shrink)
          if idx_end - idx_start < trail_length
            # Attempt to pad the beginning if we have enough pages
            # Never go beyond the zero index
            idx_start = [
              idx_start - (trail_length - (idx_end - idx_start)),
              0,
            ].max
          end

          # Convert the newpages array into a two dimensional array that has
          # [index, page_url] as items
          npage.paginator.page_trail = newpages[idx_start...idx_end]
            .each_with_index.map do |ipage, idx|
            PageTrail.new(
              idx_start + idx + 1,
              ipage.paginator.page_path,
              ipage.data["title"]
            )
          end
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
