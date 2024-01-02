# frozen_string_literal: true

module Bridgetown
  module Paginate
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

      # @return [Set<Bridgetown::Page, Bridgetown::Resource::Base>]
      def self.matching_templates
        @matching_templates ||= Set.new
      end

      def self.add_matching_template(template)
        matching_templates << template
      end

      # Generate paginated pages if necessary (Default entry point)
      # site - The Site.
      #
      # Returns nothing.
      def generate(site) # rubocop:todo Metrics/AbcSize
        # Retrieve and merge the pagination configuration from the site yml file
        default_config = Bridgetown::Utils.deep_merge_hashes(
          DEFAULT,
          site.config["pagination"] || {}
        )

        # If disabled then simply quit
        unless default_config["enabled"]
          Bridgetown.logger.info "Pagination:", "disabled. Enable in site config " \
                                                "with pagination:\\n  enabled: true"
          return
        end

        Bridgetown.logger.debug "Pagination:", "Starting"

        # Get all matching pages in the site found by the init hooks, and ensure they're
        # still in the site.generated_pages array
        templates = self.class.matching_templates.select do |page|
          site.generated_pages.include?(page) || site.resources.include?(page)
        end

        # Get the default title of the site (used as backup when there is no
        # title available for pagination)
        site_title = site.data.dig("metadata", "title") || site.config["title"]

        # Specify the callback function that returns the correct docs/posts
        # based on the collection name
        # Posts collection is the default and if the user doesn't specify a
        # collection in their front-matter then that is the one we load
        # If the collection is not found then empty array is returned
        collection_by_name_lambda = ->(collection_name) do
          coll = []
          if collection_name == "all"
            # the 'all' collection_name is a special case and includes all
            # collections in the site (except posts!!)
            # this is useful when you want to list items across multiple collections
            site.collections.each do |coll_name, collection|
              next unless !collection.nil? && coll_name != "posts"

              # Exclude all pagination pages
              coll += collection.each.reject do |doc|
                doc.data.key?("pagination") || doc.data.key?("paginate")
              end
            end
          else
            # Just the one collection requested
            return [] unless site.collections.key?(collection_name)

            # Exclude all pagination pages
            coll = site.collections[collection_name].each.reject do |doc|
              doc.data.key?("pagination") || doc.data.key?("paginate")
            end
          end
          coll
        end

        # Create the proc that constructs the real-life site page
        # This is necessary to decouple the code from the Bridgetown site object
        page_add_lambda = ->(newpage) do
          site.add_generated_page newpage
          newpage # Return the site to the calling code
        end

        # lambda that removes a page from the site pages list
        page_remove_lambda = ->(page_to_remove) do
          if page_to_remove.is_a?(Bridgetown::Resource::Base)
            page_to_remove.collection.resources.delete(page_to_remove)
          else
            site.generated_pages.delete(page_to_remove)
          end
        end

        # Create a proc that will delegate logging
        # Decoupling Bridgetown specific logging
        logging_lambda = ->(message, type = "info") do
          case type
          when "debug"
            Bridgetown.logger.debug "Pagination:", message.to_s
          when "error"
            Bridgetown.logger.error "Pagination:", message.to_s
          when "warn"
            Bridgetown.logger.warn "Pagination:", message.to_s
          else
            Bridgetown.logger.info "Pagination:", message.to_s
          end
        end

        # Now create and call the model with the real-life page creation proc and site data
        model = PaginationModel.new(
          logging_lambda,
          page_add_lambda,
          page_remove_lambda,
          collection_by_name_lambda
        )
        count = model.run(default_config, templates, site_title)
        self.class.matching_templates.clear
        Bridgetown.logger.info "Pagination:", "Complete, processed #{count} pagination page(s)"
      end
    end
  end
end
