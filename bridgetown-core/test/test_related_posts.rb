# frozen_string_literal: true

require "helper"

class TestRelatedPosts < BridgetownUnitTest
  context "building related posts without lsi" do
    setup do
      @site = fixture_site
    end

    should "use the most recent posts for related posts" do
      @site.reset
      @site.read

      last_post     = @site.posts.docs.last
      related_posts = Bridgetown::RelatedPosts.new(last_post).build

      last_ten_recent_posts = (@site.posts.docs.reverse - [last_post]).first(10)
      assert_equal last_ten_recent_posts, related_posts
    end
  end

  context "building related posts with LSI" do
    setup do
      allow_any_instance_of(Bridgetown::RelatedPosts).to receive(:display)
      @site = fixture_site(
        "lsi" => true
      )

      @site.reset
      @site.read
      require "classifier-reborn"
      Bridgetown::RelatedPosts.lsi = nil
    end

    should "index Bridgetown::Post objects" do
      @site.posts.docs = @site.posts.docs.first(1)
      expect_any_instance_of(::ClassifierReborn::LSI).to \
        receive(:add_item).with(kind_of(Bridgetown::Document))
      Bridgetown::RelatedPosts.new(@site.posts.docs.last).build_index
    end

    should "find related Bridgetown::Post objects, given a Bridgetown::Post object" do
      post = @site.posts.docs.last
      allow_any_instance_of(::ClassifierReborn::LSI).to receive(:build_index)
      expect_any_instance_of(::ClassifierReborn::LSI).to \
        receive(:find_related).with(post, 11).and_return(@site.posts.docs[-1..-9])

      Bridgetown::RelatedPosts.new(post).build
    end

    should "use LSI for the related posts" do
      allow_any_instance_of(::ClassifierReborn::LSI).to \
        receive(:find_related).and_return(@site.posts.docs[-1..-9])
      allow_any_instance_of(::ClassifierReborn::LSI).to receive(:build_index)

      assert_equal @site.posts.docs[-1..-9], Bridgetown::RelatedPosts.new(@site.posts.docs.last).build
    end

    should "not return current post" do
      allow_any_instance_of(::ClassifierReborn::LSI).to \
        receive(:find_related).and_return(@site.posts)
      allow_any_instance_of(::ClassifierReborn::LSI).to receive(:build_index)

      related_posts = Bridgetown::RelatedPosts.new(@site.posts.last).build
      refute related_posts.include?(@site.posts.last)
    end
  end
end
