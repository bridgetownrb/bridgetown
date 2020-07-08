# frozen_string_literal: true

module Bridgetown
  module Tags
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

        site.posts.docs.each do |document|
          return relative_url(document) if @post == document
        end

        # New matching method did not match, fall back to old method
        # with deprecation warning if this matches

        site.posts.docs.each do |document|
          next unless @post.deprecated_equality document

          Bridgetown::Deprecator.deprecation_message "A call to "\
            "'{% post_url #{@post.name} %}' did not match " \
            "a post using the new matching method of checking name " \
            "(path-date-slug) equality. Please make sure that you " \
            "change this tag to match the post's name exactly."
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
