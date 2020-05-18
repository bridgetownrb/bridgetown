# frozen_string_literal: true

require "helper"

class TestDocuments < BridgetownUnitTest
  context "creating a document" do
    setup do
      Bridgetown.sites.clear
      @site = Site.new(site_configuration)
      Builders::DocumentsGenerator.clear_documents_to_generate
      @generator = Builders::DocumentsGenerator.new(@site.config)
    end

    should "support front matter hashes" do
      Builders::DocumentsGenerator.add "/generated/doc.md", proc {
        front_matter({ "external" => { "data" => [1, 2, 3] } })
      }
      @generator.generate(@site)

      assert_equal 1, @site.posts.docs.length
      assert_equal [1, 2, 3], @site.posts.docs.first.data[:external][:data]
      assert_includes @site.posts.docs.first.destination(""), "/dest/generated/doc/index.html"
    end

    should "place it in a new collection" do
      Builders::DocumentsGenerator.add "learn-stuff.md", proc {
        collection :tutorials
      }
      @generator.generate(@site)

      assert_equal 1, @site.collections[:tutorials].docs.length
      assert @site.collections[:tutorials].write?
      assert_includes @site.collections[:tutorials].docs.first.destination(""), "/dest/tutorials/learn-stuff.html"
    end

    should "support standard filenames" do
      @site.config[:collections][:posts][:permalink] = "/:categories/:year/:title/"
      Builders::DocumentsGenerator.add "im-a-post.md", proc {
        title "I'm a post!"
        date "2019-05-01"
      }
      @generator.generate(@site)

      assert_includes @site.posts.docs.first.destination(""), "/dest/2019/im-a-post/index.html"
    end

    should "support date-based filenames" do
      @site.config[:collections][:posts][:permalink] = "/:categories/:year/:title/"
      Builders::DocumentsGenerator.add "2018-05-01-im-an-old-post.md", proc {
        title "I'm a post!"
      }
      @generator.generate(@site)

      assert_includes @site.posts.docs.first.destination(""), "/dest/2018/im-an-old-post/index.html"
    end
  end
end
