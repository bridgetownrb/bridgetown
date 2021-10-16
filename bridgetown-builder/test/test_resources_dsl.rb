# frozen_string_literal: true

require "helper"

class TestResources < BridgetownUnitTest
  include Bridgetown::Builders::DSL::Resources

  class Inner < Builder
    def resource_data_for_id(id)
      { title: "After a while, crocodile!" } if id == "builder://TestResources.Inner/later.html"
    end
  end

  def method_value
    "Resolved!"
  end

  context "creating a new resource" do
    setup do
      Bridgetown.sites.clear
      @site = Site.new(site_configuration)
    end

    should "support content" do
      add_resource :posts, "im-a-markdown-post.md" do
        title "I'm a Markdown post!"
        resolve_me from: -> { method_value }
        delayed -> { 123 }
        nested do
          val 456
        end
        content <<~MARKDOWN
          # Hello World!
        MARKDOWN
      end

      resource = @site.collections.posts.resources.first
      assert_equal 1, @site.collections.posts.resources.length
      assert_equal "builder://TestResources/im-a-markdown-post.md", resource.id
      assert_equal "I'm a Markdown post!", resource.data.title
      assert_equal "Resolved!", resource.model.resolve_me
      refute_equal 123, resource.model.delayed
      assert_equal 123, resource.data.delayed
      assert_equal 456, resource.data.nested.val
      assert_equal "# Hello World!", resource.content.strip
      resource.transform!
      assert_equal %(<h1 id="hello-world">Hello World!</h1>), resource.output.strip
    end

    should "support recreating data later" do
      resource = Inner.new.add_resource :page, "later.html" do
        title "Later, alligator!"
      end

      assert_equal "builder://TestResources.Inner/later.html", resource.id
      new_model = Bridgetown::Model::Base.find(resource.id)

      assert_equal "After a while, crocodile!", new_model.title
    end

    should "support front matter hashes" do
      add_resource :pages, "/generated/doc.md" do
        ___({ "external" => { "data" => [1, 2, 3] } })
      end

      assert_equal 1, @site.collections.pages.resources.length
      assert_equal [1, 2, 3], @site.collections.pages.resources.first.data[:external][:data]
      assert_includes @site.collections.pages.resources.first.destination.output_path,
                      "/dest/generated/doc/index.html"
    end

    should "place it in a new collection" do
      build_output = capture_output do
        add_resource :tutorials, "learn-stuff.md", &(proc {})
      end

      assert_includes build_output, "TestResources: Creating `tutorials' collection on the fly..."
      assert_equal 1, @site.collections[:tutorials].resources.length
      assert @site.collections[:tutorials].resources.first.write?
      assert_includes @site.collections[:tutorials].resources.first.destination.output_path,
                      "/dest/tutorials/learn-stuff/index.html"
    end

    should "support standard filenames" do
      @site.config[:collections][:posts][:permalink] = "/:categories/:year/:slug/"
      add_resource :posts, "im-a-post.md" do
        title "I'm a post!"
        date "2019-05-01"
      end

      assert_includes @site.collections.posts.resources.first.destination.output_path,
                      "/dest/2019/im-a-post/index.html"
    end

    should "support date-based filenames" do
      @site.config[:collections][:posts][:permalink] = "/:categories/:year/:slug/"
      add_resource :posts, "2018-05-01-im-an-old-post.md" do
        title "I'm a post!"
      end

      assert_includes @site.collections.posts.resources.first.destination.output_path,
                      "/dest/2018/im-an-old-post/index.html"
    end
  end
end
