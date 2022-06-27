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

      should "be processed and written to destination when passed as " \
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

  context "A GeneratedPage" do
    setup do
      clear_dest
      @site = Site.new(Bridgetown.configuration(
                         "source"            => source_dir,
                         "destination"       => dest_dir,
                         "skip_config_files" => true
                       ))
    end

    context "processing pages" do
      should "create URL based on filename" do
        @page = setup_page("contacts.html")
        assert_equal "/contacts/", @page.url
      end

      should "create proper URL from filename" do
        @page = setup_page("trailing-dots...md")
        assert_equal "/trailing-dots/", @page.url
      end

      should "create URL with non-alphabetic characters" do
        @page = setup_page("+", "%# +.md")
        assert_equal "/+/%25%23%20+/", @page.url
      end

      should "be exposed to Liquid as a Liquid::Drop subclass" do
        page = setup_page("properties.html")
        liquid_rep = page.to_liquid
        refute_equal Hash, liquid_rep.class
        assert_equal true, liquid_rep.is_a?(Liquid::Drop)
        assert_equal Bridgetown::Drops::GeneratedPageDrop, liquid_rep.class
      end

      should "make attributes accessible for use in Liquid templates" do
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

      context "in a directory hierarchy" do
        should "create URL based on filename" do
          @page = setup_page("/contacts", "bar.html")
          assert_equal "/contacts/bar/", @page.url
        end

        should "create index URL based on filename" do
          @page = setup_page("/contacts", "index.html")
          assert_equal "/contacts/", @page.url
        end
      end

      should "deal properly with extensions" do
        @page = setup_page("deal.with.dots.html")
        assert_equal ".html", @page.ext
      end

      should "deal properly with non-html extensions" do
        @page = setup_page("dynamic_page.php")
        @dest_file = dest_dir("dynamic_page.php")
        assert_equal ".php", @page.ext
        assert_equal "dynamic_page", @page.basename
        assert_equal "/dynamic_page.php", @page.url
        assert_equal @dest_file, @page.destination(dest_dir)
      end

      should "deal properly with dots" do
        @page = setup_page("deal.with.dots.html")
        @dest_file = dest_dir("deal.with.dots/index.html")

        assert_equal "deal.with.dots", @page.basename
        assert_equal @dest_file, @page.destination(dest_dir)
      end

      context "with pretty permalink style" do
        setup do
          @site.permalink_style = :pretty
        end

        should "return dir, URL, and destination correctly" do
          @page = setup_page("contacts.html")
          @dest_file = dest_dir("contacts/index.html")

          assert_equal "/contacts/", @page.dir
          assert_equal "/contacts/", @page.url
          assert_equal @dest_file, @page.destination(dest_dir)
        end

        should "return dir correctly for index page" do
          @page = setup_page("index.html")
          assert_equal "/", @page.dir
        end

        context "in a directory hierarchy" do
          should "create url based on filename" do
            @page = setup_page("/contacts", "bar.html")
            assert_equal "/contacts/bar/", @page.url
          end

          should "create index URL based on filename" do
            @page = setup_page("/contacts", "index.html")
            assert_equal "/contacts/", @page.url
          end

          should "return dir correctly" do
            @page = setup_page("/contacts", "bar.html")
            assert_equal "/contacts/bar/", @page.dir
          end

          should "return dir correctly for index page" do
            @page = setup_page("/contacts", "index.html")
            assert_equal "/contacts/", @page.dir
          end
        end
      end

      context "with date permalink style" do
        setup do
          @site.permalink_style = :date
        end

        should "return url and destination correctly" do
          @page = setup_page("contacts.html")
          @dest_file = dest_dir("contacts.html")
          assert_equal "/contacts.html", @page.url
          assert_equal @dest_file, @page.destination(dest_dir)
        end

        should "return dir correctly" do
          assert_equal "/", setup_page("contacts.html").dir
          assert_equal "/", setup_page("contacts/bar.html").dir
          assert_equal "/", setup_page("contacts/index.html").dir
        end
      end

      context "with custom permalink style with trailing slash" do
        setup do
          @site.permalink_style = "/:title/"
        end

        should "return URL and destination correctly" do
          @page = setup_page("contacts.html")
          @dest_file = dest_dir("contacts/index.html")
          assert_equal "/contacts/", @page.url
          assert_equal @dest_file, @page.destination(dest_dir)
        end
      end

      context "with custom permalink style with file extension" do
        setup do
          @site.permalink_style = "/:title:output_ext"
        end

        should "return URL and destination correctly" do
          @page = setup_page("contacts.html")
          @dest_file = dest_dir("contacts.html")
          assert_equal "/contacts.html", @page.url
          assert_equal @dest_file, @page.destination(dest_dir)
        end
      end

      context "with custom permalink style with no extension" do
        setup do
          @site.permalink_style = "/:title"
        end

        should "return URL and destination correctly" do
          @page = setup_page("contacts.html")
          @dest_file = dest_dir("contacts.html")
          assert_equal "/contacts", @page.url
          assert_equal @dest_file, @page.destination(dest_dir)
        end
      end

      context "with any other permalink style" do
        should "return dir correctly" do
          @site.permalink_style = nil
          assert_equal "/", setup_page("contacts.html").dir
          assert_equal "/", setup_page("contacts/index.html").dir
          assert_equal "/", setup_page("contacts/bar.html").dir
        end
      end

      should "not be writable outside of destination" do
        unexpected = File.expand_path("../../../baddie.html", dest_dir)
        FileUtils.rm_rf unexpected
        page = setup_page("exploit.md")
        do_render(page)
        page.write(dest_dir)

        refute_exist unexpected
      end
    end

    context "rendering" do
      setup do
        clear_dest
      end

      should "write even when permalink has '%# +'" do
        page = setup_page("+", "%# +.md")
        do_render(page)
        page.write(dest_dir)

        assert File.directory?(dest_dir)
        assert_exist dest_dir("+", "%# +", "index.html")
      end

      should "write properly without html extension" do
        page = setup_page("contacts.html")
        page.site.permalink_style = :pretty
        do_render(page)
        page.write(dest_dir)

        assert File.directory?(dest_dir)
        assert_exist dest_dir("contacts", "index.html")
      end

      should "support .htm extension and respects that" do
        page = setup_page("contacts.htm")
        page.site.permalink_style = :pretty
        do_render(page)
        page.write(dest_dir)

        assert File.directory?(dest_dir)
        assert_exist dest_dir("contacts", "index.htm")
      end

      should "support .xhtml extension and respects that" do
        page = setup_page("contacts.xhtml")
        page.site.permalink_style = :pretty
        do_render(page)
        page.write(dest_dir)

        assert File.directory?(dest_dir)
        assert_exist dest_dir("contacts", "index.xhtml")
      end

      should "write properly with extension different from html" do
        page = setup_page("sitemap.xml")
        page.site.permalink_style = :pretty
        do_render(page)
        page.write(dest_dir)

        assert_equal "/sitemap.xml", page.url
        assert_nil page.url[%r!\.html$!]
        assert File.directory?(dest_dir)
        assert_exist dest_dir("sitemap.xml")
      end

      should "write dotfiles properly" do
        page = setup_page(".htaccess")
        do_render(page)
        page.write(dest_dir)

        assert File.directory?(dest_dir)
        assert_exist dest_dir(".htaccess")
      end

      context "in a directory hierarchy" do
        should "write properly the index" do
          page = setup_page("/contacts", "index.html")
          do_render(page)
          page.write(dest_dir)

          assert File.directory?(dest_dir)
          assert_exist dest_dir("contacts", "index.html")
        end

        should "write properly" do
          page = setup_page("/contacts", "bar.html")
          do_render(page)
          page.write(dest_dir)

          assert File.directory?(dest_dir)
          assert_exist dest_dir("contacts", "bar", "index.html")
        end

        should "write properly without html extension" do
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
