# frozen_string_literal: true

module Bridgetown
  module Paginate
    module Generator
      #
      # The main entry point into the generator, called by Bridgetown
      # this function extracts all the necessary information from the Bridgetown
      # end and passes it into the pagination logic. Additionally it also
      # contains all site specific actions that the pagination logic needs access
      # to (such as how to create new pages)
      #
      class PaginationGenerator < Bridgetown::Generator
        # This generator should be passive with regard to its execution
        priority :lowest

        # Generate paginated pages if necessary (Default entry point)
        # site - The Site.
        #
        # Returns nothing.
        def generate(site)
          # Retrieve and merge the pagination configuration from the site yml file
          default_config = Bridgetown::Utils.deep_merge_hashes(
            DEFAULT,
            site.config["pagination"] || {}
          )

          # If disabled then simply quit
          unless default_config["enabled"]
            Bridgetown.logger.info "Pagination:", "disabled. Enable in site config with pagination:\\n  enabled: true"
            return
          end

          Bridgetown.logger.debug "Pagination:", "Starting"

          ################ 0 ####################
          # Get all pages in the site (this will be used to find the pagination
          # templates)
          all_pages = site.pages

          # Get the default title of the site (used as backup when there is no
          # title available for pagination)
          site_title = site.data.dig("metadata", "title") || site.config["title"]

          ################ 1 ####################
          # Specify the callback function that returns the correct docs/posts
          # based on the collection name
          # "posts" are just another collection in Bridgetown but a specialized
          # version that require timestamps
          # This collection is the default and if the user doesn't specify a
          # collection in their front-matter then that is the one we load
          # If the collection is not found then empty array is returned
          collection_by_name_lambda = lambda do |collection_name|
            coll = []
            if collection_name == "all"
              # the 'all' collection_name is a special case and includes all
              # collections in the site (except posts!!)
              # this is useful when you want to list items across multiple collections
              site.collections.each do |coll_name, coll_data|
                next unless !coll_data.nil? && coll_name != "posts"

                # Exclude all pagination pages
                coll += coll_data.docs.reject do |doc|
                  doc.data.key?("pagination")
                end
              end
            else
              # Just the one collection requested
              return [] unless site.collections.key?(collection_name)

              # Exclude all pagination pages
              coll = site.collections[collection_name].docs.reject do |doc|
                doc.data.key?("pagination")
              end
            end
            return coll
          end

          ################ 2 ####################
          # Create the proc that constructs the real-life site page
          # This is necessary to decouple the code from the Bridgetown site object
          page_add_lambda = lambda do |newpage|
            site.pages << newpage # Add the page to the site so that it is generated correctly
            return newpage # Return the site to the calling code
          end

          ################ 2.5 ####################
          # lambda that removes a page from the site pages list
          page_remove_lambda = lambda do |page_to_remove|
            site.pages.delete_if { |page| page == page_to_remove }
          end

          ################ 3 ####################
          # Create a proc that will delegate logging
          # Decoupling Bridgetown specific logging
          logging_lambda = lambda do |message, type = "info"|
            if type == "debug"
              Bridgetown.logger.debug "Pagination:", message.to_s
            elsif type == "error"
              Bridgetown.logger.error "Pagination:", message.to_s
            elsif type == "warn"
              Bridgetown.logger.warn "Pagination:", message.to_s
            else
              Bridgetown.logger.info "Pagination:", message.to_s
            end
          end

          ################ 4 ####################
          # Now create and call the model with the real-life page creation proc and site data
          model = PaginationModel.new(
            logging_lambda,
            page_add_lambda,
            page_remove_lambda,
            collection_by_name_lambda
          )
          count = model.run(default_config, all_pages, site_title)
          Bridgetown.logger.info "Pagination:", "Complete, processed #{count} pagination page(s)"
        end
      end
    end
  end
end
