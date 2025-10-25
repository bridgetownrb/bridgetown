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

  def do_render(page)
    page.transform!
  end

  def render_and_write
    @site.render
    @site.cleanup
    @site.write
  end

  describe "A GeneratedPage" do
    before do
      clear_dest
      @site = Site.new(Bridgetown.configuration(
                         "source"            => source_dir,
                         "destination"       => dest_dir,
                         "skip_config_files" => true
                       ))
    end

    describe "with default site configuration" do
      before do
        @page = setup_page("properties.html")
      end

      it "identifies itself properly" do
        assert_equal "#<Bridgetown::GeneratedPage properties.html>",
                     @page.inspect
      end

      it "does not have page-content and page-data defined within it" do
        assert_equal "generated_pages", @page.type.to_s
        assert_nil @page.content
        assert_empty @page.data
      end
    end

    describe "with site-wide permalink configuration" do
      before do
        @site.permalink_style = :title
      end

      it "generates page url accordingly" do
        page = setup_page("properties.html")
        assert_equal "/properties", page.url
      end
    end

    describe "with a path outside site.source" do
      it "does not access its contents" do
        base = "../../../"
        page = setup_page("pwd", base:)

        assert_equal "pwd", page.path
        assert_nil page.content
      end
    end

    describe "while processing" do
      before do
        clear_dest
        @site.config["title"] = "Test Site"
        @page = setup_page("physical.html", base: testing_dir("fixtures"))
      end

      it "receives content provided to it" do
        assert_nil @page.content

        @page.content = "{{ site.title }}"
        assert_equal "{{ site.title }}", @page.content
      end

      it "does not be processed and written to disk at destination" do
        @page.content = "Lorem ipsum dolor sit amet"
        @page.data["permalink"] = "/virtual-about/"

        render_and_write

        refute_exist dest_dir("physical")
        refute_exist dest_dir("virtual-about")
        refute File.exist?(dest_dir("virtual-about", "index.html"))
      end

      it "is processed and written to destination when passed as " \
         "an entry in 'site.generated_pages' array" do
        @page.content = "{{ site.title }}"
        @page.data["permalink"] = "/virtual-about/"
        @page.data["template_engine"] = "liquid"

        @site.generated_pages << @page
        render_and_write

        refute_exist dest_dir("physical")
        assert_exist dest_dir("virtual-about")
        assert File.exist?(dest_dir("virtual-about", "index.html"))
        assert_equal "Test Site", File.read(dest_dir("virtual-about", "index.html"))
      end
    end
  end

  describe "A GeneratedPage" do
    before do
      clear_dest
      @site = Site.new(Bridgetown.configuration(
                         "source"            => source_dir,
                         "destination"       => dest_dir,
                         "skip_config_files" => true
                       ))
    end

    describe "processing pages" do
      it "creates URL based on filename" do
        @page = setup_page("contacts.html")
        assert_equal "/contacts/", @page.url
      end

      it "creates proper URL from filename" do
        @page = setup_page("trailing-dots...md")
        assert_equal "/trailing-dots/", @page.url
      end

      it "creates URL with non-alphabetic characters" do
        @page = setup_page("+", "%# +.md")
        assert_equal "/+/%25%23%20+/", @page.url
      end

      it "is exposed to Liquid as a Liquid::Drop subclass" do
        page = setup_page("properties.html")
        liquid_rep = page.to_liquid
        refute_equal Hash, liquid_rep.class
        assert_equal true, liquid_rep.is_a?(Liquid::Drop)
        assert_equal Bridgetown::Drops::GeneratedPageDrop, liquid_rep.class
      end

      it "makes attributes accessible for use in Liquid templates" do
        page = setup_page("/contacts", "index.html")
        template = Liquid::Template.parse(<<~TEXT)
          Name: {{ page.name }}
          Path: {{ page.path }}
          URL:  {{ page.url }}
        TEXT
        expected = <<~TEXT
          Name: index.html
          Path: contacts/index.html
          URL:  /contacts/
        TEXT
        assert_equal(expected, template.render!("page" => page.to_liquid))
      end

      describe "in a directory hierarchy" do
        it "creates URL based on filename" do
          @page = setup_page("/contacts", "bar.html")
          assert_equal "/contacts/bar/", @page.url
        end

        it "creates index URL based on filename" do
          @page = setup_page("/contacts", "index.html")
          assert_equal "/contacts/", @page.url
        end
      end

      it "deals properly with extensions" do
        @page = setup_page("deal.with.dots.html")
        assert_equal ".html", @page.ext
      end

      it "deals properly with non-html extensions" do
        @page = setup_page("dynamic_page.php")
        @dest_file = dest_dir("dynamic_page.php")
        assert_equal ".php", @page.ext
        assert_equal "dynamic_page", @page.basename
        assert_equal "/dynamic_page.php", @page.url
        assert_equal @dest_file, @page.destination(dest_dir)
      end

      it "deals properly with dots" do
        @page = setup_page("deal.with.dots.html")
        @dest_file = dest_dir("deal.with.dots/index.html")

        assert_equal "deal.with.dots", @page.basename
        assert_equal @dest_file, @page.destination(dest_dir)
      end

      describe "with pretty permalink style" do
        before do
          @site.permalink_style = :pretty
        end

        it "returns dir, URL, and destination correctly" do
          @page = setup_page("contacts.html")
          @dest_file = dest_dir("contacts/index.html")

          assert_equal "/contacts/", @page.dir
          assert_equal "/contacts/", @page.url
          assert_equal @dest_file, @page.destination(dest_dir)
        end

        it "returns dir correctly for index page" do
          @page = setup_page("index.html")
          assert_equal "/", @page.dir
        end

        describe "in a directory hierarchy" do
          it "creates url based on filename" do
            @page = setup_page("/contacts", "bar.html")
            assert_equal "/contacts/bar/", @page.url
          end

          it "creates index URL based on filename" do
            @page = setup_page("/contacts", "index.html")
            assert_equal "/contacts/", @page.url
          end

          it "returns dir correctly" do
            @page = setup_page("/contacts", "bar.html")
            assert_equal "/contacts/bar/", @page.dir
          end

          it "returns dir correctly for index page" do
            @page = setup_page("/contacts", "index.html")
            assert_equal "/contacts/", @page.dir
          end
        end
      end

      describe "with custom permalink style with trailing slash" do
        before do
          @site.permalink_style = "/:title/"
        end

        it "returns URL and destination correctly" do
          @page = setup_page("contacts.html")
          @dest_file = dest_dir("contacts/index.html")
          assert_equal "/contacts/", @page.url
          assert_equal @dest_file, @page.destination(dest_dir)
        end
      end

      describe "with custom permalink style with file extension" do
        before do
          @site.permalink_style = "/:title.*"
        end

        it "returns URL and destination correctly" do
          @page = setup_page("contacts.html")
          @dest_file = dest_dir("contacts.html")
          assert_equal "/contacts.html", @page.url
          assert_equal @dest_file, @page.destination(dest_dir)
        end
      end

      describe "with custom permalink style with no extension" do
        before do
          @site.permalink_style = "/:title"
        end

        it "returns URL and destination correctly" do
          @page = setup_page("contacts.html")
          @dest_file = dest_dir("contacts.html")
          assert_equal "/contacts", @page.url
          assert_equal @dest_file, @page.destination(dest_dir)
        end
      end

      describe "with any other permalink style" do
        it "returns dir correctly" do
          @site.permalink_style = nil
          assert_equal "/", setup_page("contacts.html").dir
          assert_equal "/", setup_page("contacts/index.html").dir
          assert_equal "/", setup_page("contacts/bar.html").dir
        end
      end

      it "does not be writable outside of destination" do
        unexpected = File.expand_path("../../../baddie.html", dest_dir)
        FileUtils.rm_rf unexpected
        page = setup_page("exploit.md")
        do_render(page)
        page.write(dest_dir)

        refute_exist unexpected
      end
    end

    describe "rendering" do
      before do
        clear_dest
      end

      it "writes even when permalink has '%# +'" do
        page = setup_page("+", "%# +.md")
        do_render(page)
        page.write(dest_dir)

        assert File.directory?(dest_dir)
        assert_exist dest_dir("+", "%# +", "index.html")
      end

      it "writes properly without html extension" do
        page = setup_page("contacts.html")
        page.site.permalink_style = :pretty
        do_render(page)
        page.write(dest_dir)

        assert File.directory?(dest_dir)
        assert_exist dest_dir("contacts", "index.html")
      end

      it "supports .htm extension and respects that" do
        page = setup_page("contacts.htm")
        page.site.permalink_style = :pretty
        do_render(page)
        page.write(dest_dir)

        assert File.directory?(dest_dir)
        assert_exist dest_dir("contacts", "index.htm")
      end

      it "supports .xhtml extension and respects that" do
        page = setup_page("contacts.xhtml")
        page.site.permalink_style = :pretty
        do_render(page)
        page.write(dest_dir)

        assert File.directory?(dest_dir)
        assert_exist dest_dir("contacts", "index.xhtml")
      end

      it "writes properly with extension different from html" do
        page = setup_page("sitemap.xml")
        page.site.permalink_style = :pretty
        do_render(page)
        page.write(dest_dir)

        assert_equal "/sitemap.xml", page.url
        assert_nil page.url[%r!\.html$!]
        assert File.directory?(dest_dir)
        assert_exist dest_dir("sitemap.xml")
      end

      it "writes dotfiles properly" do
        page = setup_page(".htaccess")
        do_render(page)
        page.write(dest_dir)

        assert File.directory?(dest_dir)
        assert_exist dest_dir(".htaccess")
      end

      describe "in a directory hierarchy" do
        it "writes properly the index" do
          page = setup_page("/contacts", "index.html")
          do_render(page)
          page.write(dest_dir)

          assert File.directory?(dest_dir)
          assert_exist dest_dir("contacts", "index.html")
        end

        it "writes properly" do
          page = setup_page("/contacts", "bar.html")
          do_render(page)
          page.write(dest_dir)

          assert File.directory?(dest_dir)
          assert_exist dest_dir("contacts", "bar", "index.html")
        end

        it "writes properly without html extension" do
          page = setup_page("/contacts", "bar.html")
          page.site.permalink_style = :pretty
          do_render(page)
          page.write(dest_dir)

          assert File.directory?(dest_dir)
          assert_exist dest_dir("contacts", "bar", "index.html")
        end
      end
    end
  end
end
