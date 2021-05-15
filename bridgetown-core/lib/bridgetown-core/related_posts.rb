# frozen_string_literal: true

module Bridgetown
  # TODO: to be retired once the Resource engine is made official
  class RelatedPosts
    class << self
      attr_accessor :lsi
    end

    attr_reader :post, :site

    def initialize(post)
      @post = post
      @site = post.site
      Bridgetown::Utils::RequireGems.require_with_graceful_fail("classifier-reborn") if site.lsi
    end

    def build
      return [] unless site.collections.posts.docs.size > 1

      if site.lsi
        build_index
        lsi_related_posts
      else
        most_recent_posts
      end
    end

    def build_index
      self.class.lsi ||= begin
        lsi = ClassifierReborn::LSI.new(auto_rebuild: false)
        Bridgetown.logger.info("Populating LSI...")

        site.collections.posts.docs.each do |x|
          lsi.add_item(x)
        end

        Bridgetown.logger.info("Rebuilding index...")
        lsi.build_index
        Bridgetown.logger.info("")
        lsi
      end
    end

    def lsi_related_posts
      self.class.lsi.find_related(post, 11) - [post]
    end

    def most_recent_posts
      @most_recent_posts ||= (site.collections.posts.docs.last(11).reverse - [post]).first(10)
    end
  end
end
