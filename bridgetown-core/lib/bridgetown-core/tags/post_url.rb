# frozen_string_literal: true

module Bridgetown
  module Tags
    class PostComparer
      MATCHER = %r!^(.+/)*(\d+-\d+-\d+)-(.*)$!.freeze

      attr_reader :path, :date, :slug, :name

      def initialize(name)
        @name = name

        all, @path, @date, @slug = *name.sub(%r!^/!, "").match(MATCHER)
        unless all
          raise Bridgetown::Errors::InvalidPostNameError,
                "'#{name}' does not contain valid date and/or title."
        end

        escaped_slug = Regexp.escape(slug)
        @name_regex = %r!^_posts/#{path}#{date}-#{escaped_slug}\.[^.]+|
          ^#{path}_posts/?#{date}-#{escaped_slug}\.[^.]+!x
      end

      def post_date
        @post_date ||= Utils.parse_date(
          date,
          "'#{date}' does not contain valid date and/or title."
        )
      end

      def ==(other)
        other.relative_path.to_s.match(@name_regex)
      end

      def deprecated_equality(other)
        slug == post_slug(other) &&
          post_date.year  == other.date.year &&
          post_date.month == other.date.month &&
          post_date.day   == other.date.day
      end

      private

      # Construct the directory-aware post slug for a Bridgetown::Post
      #
      # other - the Bridgetown::Post
      #
      # Returns the post slug with the subdirectory (relative to _posts)
      def post_slug(other)
        other.data.slug
      end
    end

    class PostUrl < Liquid::Tag
      include Bridgetown::Filters::URLFilters

      def initialize(tag_name, post, tokens)
        super
        @orig_post = post.strip
        begin
          @post = PostComparer.new(@orig_post)
        rescue StandardError => e
          raise Bridgetown::Errors::PostURLError, <<~MSG
            Could not parse name of post "#{@orig_post}" in tag 'post_url'.
             Make sure the post exists and the name is correct.
             #{e.class}: #{e.message}
          MSG
        end
      end

      def render(context)
        @context = context
        site = context.registers[:site]

        site.collections.posts.resources.each do |document|
          return relative_url(document) if @post == document

          # New matching method did not match, fall back to old method
          # with deprecation warning if this matches
          next unless @post.deprecated_equality document

          Bridgetown::Deprecator.deprecation_message(
            "A call to " \
            "'{% post_url #{@post.name} %}' did not match " \
            "a post using the new matching method of checking name " \
            "(path-date-slug) equality. Please make sure that you " \
            "change this tag to match the post's name exactly."
          )

          return relative_url(document)
        end

        raise Bridgetown::Errors::PostURLError, <<~MSG
          Could not find post "#{@orig_post}" in tag 'post_url'.
          Make sure the post exists and the name is correct.
        MSG
      end
    end
  end
end

Liquid::Template.register_tag("post_url", Bridgetown::Tags::PostUrl)
