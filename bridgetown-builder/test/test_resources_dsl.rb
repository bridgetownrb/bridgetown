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

  def upcased_content
    resource ? resource.content.upcase : "NOPE"
  end

  attr_reader :site

  context "creating a new resource" do
    setup do
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

      assert_raises Bridgetown::Errors::FatalException do
        Bridgetown::Model::Base.find("builder://TestResources.Inner/nope.html")
      end
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

  context "extending resources" do
    setup do
      @site = Site.new(site_configuration)
    end

    should "add a new method" do
      define_resource_method :upcased_title do
        data.title.upcase
      end
      define_resource_method :upcased_content
      define_resource_method :resource_class_name, class_scope: true do
        "All your #{name} are belong to us!"
      end

      assert_equal "All your Bridgetown::Resource::Base are belong to us!",
                   Bridgetown::Resource::Base.resource_class_name

      add_resource :posts, "im-a-markdown-post.html" do
        title "I'm a post!"
        content "Yay!"
      end

      resource = @site.collections[:posts].resources.first
      assert_equal 1, @site.collections[:posts].resources.length
      assert_equal "I'M A POST!", resource.upcased_title
      assert_equal "YAY!", resource.upcased_content
      assert_equal "NOPE", upcased_content
    end

    should "allow new summaries" do
      add_resource :posts, "im-a-markdown-post.html" do
        title "I'm a post!"
        content "This is my content."
      end

      assert_equal "This is my content.", @site.collections[:posts].resources.first.summary

      define_resource_method :summary_extension_output do
        content.sub("my", "MY")
      end

      assert_equal "This is MY content.", @site.collections[:posts].resources.first.summary
    end
  end

  context "adding a permalink placeholder" do
    setup do
      @site = Site.new(site_configuration)
    end

    should "update the permalink" do
      permalink_placeholder :bar do |resource|
        resource.data.title.split.last.delete_suffix("!")
      end

      add_resource :posts, "im-a-post.md" do
        title "I'm a post!"
        permalink "/foo/:bar/"
      end

      assert_equal "/foo/post/", @site.resources.first.relative_url
    end
  end
end
