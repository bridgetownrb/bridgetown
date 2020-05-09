# frozen_string_literal: true

require "helper"

class TestDocuments < BridgetownUnitTest
  context "creating a document" do
    setup do
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
    end

    should "place it in a new collection" do
      Builders::DocumentsGenerator.add "/generated/doc.md", proc {
        collection :tutorials
      }
      @generator.generate(@site)

      assert_equal 1, @site.collections[:tutorials].docs.length
      assert @site.collections[:tutorials].write?
    end

    should "support standard filenames" do
      @site.config[:collections][:posts][:permalink] = "/:categories/:year/:title/"
      Builders::DocumentsGenerator.add "im-a-post.md", proc {
        title "I'm a post!"
        date Utils.parse_date("2020-05-01")
      }
      @generator.generate(@site)

      assert_includes @site.posts.docs.first.destination(""), "/dest/2020/im-a-post/index.html"
    end
  end
end
