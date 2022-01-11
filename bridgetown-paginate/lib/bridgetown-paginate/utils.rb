# frozen_string_literal: true

module Bridgetown
  module Paginate
    # Static utility functions that are used in the code and
    # don't belong in once place in particular
    class Utils
      # Static: Calculate the number of pages.
      #
      # all_posts - The Array of all Posts.
      # per_page  - The Integer of entries per page.
      #
      # Returns the Integer number of pages.
      def self.calculate_number_of_pages(all_posts, per_page)
        (all_posts.size.to_f / per_page.to_i).ceil
      end

      # Static: returns a fully formatted string with the current (:num) page
      # number and maximum (:max) page count replaced if configured
      #
      def self.format_page_number(to_format, cur_page_nr, total_page_count = nil)
        s = to_format.sub(":num", cur_page_nr.to_s)
        s = s.sub(":max", total_page_count.to_s) unless total_page_count.nil?

        s
      end

      # Static: returns a fully formatted string with the :title variable and
      # the current (:num) page number and maximum (:max) page count replaced
      #
      def self.format_page_title(to_format, title, cur_page_nr = nil, total_page_count = nil)
        format_page_number(to_format.sub(":title", title.to_s), cur_page_nr, total_page_count)
      end

      # Static: Return a String version of the input which has a leading dot.
      #         If the input already has a dot in position zero, it will be
      #         returned unchanged.
      #
      # @param path [String]
      # @return [String] the path with a leading slash
      def self.ensure_leading_dot(path)
        path[0..0] == "." ? path : ".#{path}"
      end

      # Static: Return a String version of the input which has a leading slash.
      #         If the input already has a forward slash in position zero, it will be
      #         returned unchanged.
      #
      # @param path [String]
      # @return [String] the path with a leading slash
      def self.ensure_leading_slash(path)
        path[0..0] == "/" ? path : "/#{path}"
      end

      # Static: Return a String version of the input with only one leading slash.
      #
      # @param path [String]
      # @return [String] the input without the leading slash
      def self.remove_double_slash(path)
        path[0..1] == "//" ? path[1..] : path
      end

      # Static: Return a String version of the input which has a trailing slash.
      #         If the input already has a forward slash at the end, it will be
      #         returned unchanged.
      #
      # @param path [String]
      # @return [String] the path with a trailing slash
      def self.ensure_trailing_slash(path)
        path[-1] == "/" ? path : "#{path}/"
      end

      #
      # Sorting routine used for ordering posts by custom fields.
      # Handles Strings separately as we want a case-insenstive sorting
      #
      # rubocop:disable Naming/MethodParameterName, Metrics/CyclomaticComplexity
      def self.sort_values(a, b)
        return -1 if a.nil? && !b.nil?
        return 1 if !a.nil? && b.nil?
        return a.downcase <=> b.downcase if a.is_a?(String)

        if a.respond_to?(:to_datetime) && b.respond_to?(:to_datetime)
          return a.to_datetime <=> b.to_datetime
        end

        # By default use the built in sorting for the data type
        a <=> b
      end
      # rubocop:enable Naming/MethodParameterName, Metrics/CyclomaticComplexity

      # Retrieves the given sort field from the given post
      # the sort_field variable can be a hierarchical value on the form
      # "parent_field:child_field" repeated as many times as needed
      # only the leaf child_field will be retrieved
      def self.sort_get_post_data(post_data, sort_field)
        # Begin by splitting up the sort_field by (;,:.)
        sort_split = sort_field.split(":")
        sort_value = post_data

        sort_split.each do |r_key|
          key = r_key.downcase.strip # Remove any erronious whitespace and convert to lower case
          return nil unless sort_value.key?(key)

          # Work my way through the hash
          sort_value = sort_value[key]
        end

        # If the sort value is a hash then return nil else return the value
        if sort_value.is_a?(Hash)
          nil
        else
          sort_value
        end
      end

      # Ensures that the passed in url has a index and extension applied
      def self.ensure_full_path(url, default_index, default_ext)
        if url.end_with?("/")
          url + default_index + default_ext
        elsif !url.include?(".")
          url + default_index
        else
          url
        end
      end
    end
  end
end
