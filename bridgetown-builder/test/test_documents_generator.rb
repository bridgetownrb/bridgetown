# frozen_string_literal: true

require "helper"

class TestDocumentsGenerator < BridgetownUnitTest
  context "adding a document" do
    setup do
      Bridgetown.sites.clear
      @site = Site.new(site_configuration)
      Builders::DocumentsGenerator.clear_documents_to_generate
      @generator = Builders::DocumentsGenerator.new(@site.config)
    end

    should "insert it into site documents" do
      Builders::DocumentsGenerator.add "/generated/doc.md", proc {
        title "I'm a Document"
      }
      @generator.generate(@site)

      assert_equal 1, @site.posts.docs.length
      assert_equal "I'm a Document", @site.posts.docs.first.data[:title]
      assert_equal "/generated/doc/", @site.posts.docs.first.url
      assert_includes @site.posts.docs.first.destination(""), "/dest/generated/doc/index.html"
    end
  end
end
