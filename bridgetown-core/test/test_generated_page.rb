# frozen_string_literal: true

require "helper"

class TestGeneratedPage < BridgetownUnitTest
  def setup_page(*args, base: source_dir, klass: GeneratedPage)
    dir, file = args
    if file.nil?
      file = dir
      dir = ""
    end
    klass.new(@site, base, dir, file)
  end

  def render_and_write
    @site.render
    @site.cleanup
    @site.write
  end

  context "A GeneratedPage" do
    setup do
      clear_dest
      @site = Site.new(Bridgetown.configuration(
                         "source"            => source_dir,
                         "destination"       => dest_dir,
                         "skip_config_files" => true
                       ))
    end

    context "with default site configuration" do
      setup do
        @page = setup_page("properties.html")
      end

      should "identify itself properly" do
        assert_equal "#<Bridgetown::GeneratedPage properties.html>",
                     @page.inspect
      end

      should "not have page-content and page-data defined within it" do
        assert_equal "generated_pages", @page.type.to_s
        assert_nil @page.content
        assert_empty @page.data
      end
    end

    context "with site-wide permalink configuration" do
      setup do
        @site.permalink_style = :title
      end

      should "generate page url accordingly" do
        page = setup_page("properties.html")
        assert_equal "/properties", page.url
      end
    end

    context "with a path outside site.source" do
      should "not access its contents" do
        base = "../../../"
        page = setup_page("pwd", base: base)

        assert_equal "pwd", page.path
        assert_nil page.content
      end
    end

    context "while processing" do
      setup do
        clear_dest
        @site.config["title"] = "Test Site"
        @page = setup_page("physical.html", base: test_dir("fixtures"))
      end

      should "receive content provided to it" do
        assert_nil @page.content

        @page.content = "{{ site.title }}"
        assert_equal "{{ site.title }}", @page.content
      end

      should "not be processed and written to disk at destination" do
        @page.content = "Lorem ipsum dolor sit amet"
        @page.data["permalink"] = "/virtual-about/"

        render_and_write

        refute_exist dest_dir("physical")
        refute_exist dest_dir("virtual-about")
        refute File.exist?(dest_dir("virtual-about", "index.html"))
      end

      should "be processed and written to destination when passed as "\
        "an entry in 'site.generated_pages' array" do
        @page.content = "{{ site.title }}"
        @page.data["permalink"] = "/virtual-about/"

        @site.generated_pages << @page
        render_and_write

        refute_exist dest_dir("physical")
        assert_exist dest_dir("virtual-about")
        assert File.exist?(dest_dir("virtual-about", "index.html"))
        assert_equal "Test Site", File.read(dest_dir("virtual-about", "index.html"))
      end
    end
  end
end
