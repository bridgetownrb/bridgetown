# frozen_string_literal: true

module Bridgetown
  module Tags
    class PostComparer
      MATCHER = %r!^(.+/)*(\d+-\d+-\d+)-(.*)$!

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

          next
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
