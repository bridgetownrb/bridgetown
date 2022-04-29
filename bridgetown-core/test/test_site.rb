# frozen_string_literal: true

require "helper"

class TestSite < BridgetownUnitTest
  context "configuring sites" do
    should "default base_path to `/`" do
      site = Site.new(Bridgetown::Configuration::DEFAULTS.deep_dup)
      assert_equal "/", site.base_path
    end

    should "expose base_path passed in from config" do
      site = Site.new(site_configuration("base_path" => "/blog"))
      assert_equal "/blog", site.base_path
    end

    should "configure cache_dir" do
      fixture_site.process
      assert File.directory?(
        site_root_dir(".bridgetown-cache", "Bridgetown", "Cache")
      )
      assert File.directory?(
        site_root_dir(".bridgetown-cache", "Bridgetown", "Cache",
                      "Bridgetown--Cache")
      )
    end

    should "use .bridgetown-cache directory at root as cache_dir by default" do
      site = Site.new(Bridgetown::Configuration::DEFAULTS.deep_dup)
      assert_equal File.join(site.root_dir, ".bridgetown-cache"), site.cache_dir
    end
  end

  context "creating sites" do
    setup do
      @site = Site.new(site_configuration)
      @num_invalid_posts = 8
    end

    teardown do
      self.class.send(:remove_const, :MyGenerator) if defined?(MyGenerator)
    end

    should "have an empty tag hash by default" do
      assert_equal({}, @site.tags)
    end

    should "reset data before processing" do
      clear_dest
      @site.process
      before_posts = @site.collections.posts.resources.length
      before_layouts = @site.layouts.length
      before_categories = @site.categories.length
      before_tags = @site.tags.length
      before_pages = @site.generated_pages.length
      before_static_files = @site.static_files.length
      before_time = @site.time

      @site.process
      assert_equal before_posts, @site.collections.posts.resources.length
      assert_equal before_layouts, @site.layouts.length
      assert_equal before_categories, @site.categories.length
      assert_equal before_tags, @site.tags.length
      assert_equal before_pages, @site.generated_pages.length
      assert_equal before_static_files, @site.static_files.length
      assert before_time <= @site.time
    end

    should "write only modified static files" do
      clear_dest
      StaticFile.reset_cache

      @site.process
      some_static_file = @site.static_files[0].path
      dest = File.expand_path(@site.static_files[0].destination(@site.dest))
      mtime1 = File.stat(dest).mtime.to_i # first run must generate dest file

      # need to sleep because filesystem timestamps have best resolution in seconds
      sleep 1
      @site.process
      mtime2 = File.stat(dest).mtime.to_i
      assert_equal mtime1, mtime2

      # simulate file modification by user
      FileUtils.touch some_static_file

      sleep 1
      @site.process
      mtime3 = File.stat(dest).mtime.to_i
      refute_equal mtime2, mtime3 # must be regenerated!

      sleep 1
      @site.process
      mtime4 = File.stat(dest).mtime.to_i
      assert_equal mtime3, mtime4 # no modifications, so must be the same
    end

    should "write static files if not modified but missing in destination" do
      clear_dest
      StaticFile.reset_cache

      @site.process
      dest = File.expand_path(@site.static_files[0].destination(@site.dest))
      mtime1 = File.stat(dest).mtime.to_i # first run must generate dest file

      # need to sleep because filesystem timestamps have best resolution in seconds
      sleep 1
      @site.process
      mtime2 = File.stat(dest).mtime.to_i
      assert_equal mtime1, mtime2

      # simulate destination file deletion
      File.unlink dest
      refute File.exist?(dest)

      sleep 1
      @site.process
      mtime3 = File.stat(dest).mtime.to_i
      assert_equal mtime2, mtime3 # must be regenerated and with original mtime!

      sleep 1
      @site.process
      mtime4 = File.stat(dest).mtime.to_i
      assert_equal mtime3, mtime4 # no modifications, so remain the same
    end

    should "setup plugins in priority order" do
      assert_equal(
        @site.converters.sort_by(&:class).map { |c| c.class.priority },
        @site.converters.map { |c| c.class.priority }
      )
      assert_equal(
        @site.generators.sort_by(&:class).map { |g| g.class.priority },
        @site.generators.map { |g| g.class.priority }
      )
    end

    should "sort pages alphabetically" do
      clear_dest
      method = Dir.method(:entries)
      allow(Dir).to receive(:entries) do |*args, &block|
        method.call(*args, &block).reverse
      end
      @site.process

      # rubocop:disable Style/WordArray
      sorted_pages = %w(
        %#\ +.md
        .htaccess
        about.html
        application.coffee
        bar.html
        coffeescript.coffee
        components.html
        contacts.html
        deal.with.dots.html
        dynamic_file.php
        environment.html
        exploit.md
        foo.md
        humans.txt
        index.html
        info.md
        layouts.html
        layouts_override.html
        main.scss
        page_from_a_plugin.html
        page_using_erb.erb
        page_using_serb.serb
        properties.html
        rails-style.html.erb
        sitemap.xml
        static_files.html
        symlinked-file
        trailing-dots...md
      )
      # rubocop:enable Style/WordArray

      assert_equal sorted_pages, @site.collections.pages.resources.map { |page| page.relative_path.basename.to_s }.sort!.uniq!
    end

    should "read pages with YAML front matter" do
      abs_path = File.expand_path("about.html", @site.source)
      assert_equal true, Utils.has_yaml_header?(abs_path)
    end

    should "enforce a strict 3-dash limit on the start of the YAML front matter" do
      abs_path = File.expand_path("pgp.key", @site.source)
      assert_equal false, Utils.has_yaml_header?(abs_path)
    end

    should "expose bridgetown version to site payload" do
      assert_equal Bridgetown::VERSION, @site.site_payload["bridgetown"]["version"]
    end

    should "expose list of static files to site payload" do
      assert_equal @site.static_files, @site.site_payload["site"]["static_files"]
    end

    should "deploy payload" do
      clear_dest
      @site.process

      posts = Dir[source_dir("_posts", "**", "*")]
      posts.delete_if do |post|
        File.directory?(post) && post !~ Bridgetown::Resource::Base::DATE_FILENAME_MATCHER
      end
      categories = %w(
        2013 bar baz foo z_category MixedCase Mixedcase test_post_reader publish_test
      ).sort

      assert_equal posts.size - @num_invalid_posts, @site.collections.posts.resources.size
      assert_equal categories, @site.categories.keys.map(&:to_s).sort
      assert_equal 4, @site.categories["foo"].size
    end

    context "error handling" do
      should "raise if destination is included in source" do
        assert_raises Bridgetown::Errors::FatalException do
          Site.new(site_configuration("destination" => source_dir))
        end
      end

      should "raise if destination is source" do
        assert_raises Bridgetown::Errors::FatalException do
          Site.new(site_configuration("destination" => File.join(source_dir, "..")))
        end
      end

      should "raise for bad frontmatter if strict_front_matter is set" do
        site = Site.new(site_configuration(
                          "collections"         => ["broken"],
                          "strict_front_matter" => true
                        ))
        assert_raises(Psych::SyntaxError) do
          site.process
        end
      end

      should "not raise for bad frontmatter if strict_front_matter is not set" do
        site = Site.new(site_configuration(
                          "collections"         => ["broken"],
                          "strict_front_matter" => false
                        ))
        site.process
      end
    end

    context "with orphaned files in destination" do
      setup do
        clear_dest
        @site.process
        # generate some orphaned files:
        # single file
        FileUtils.touch(dest_dir("obsolete.html"))
        # single file in sub directory
        FileUtils.mkdir(dest_dir("qux"))
        FileUtils.touch(dest_dir("qux/obsolete.html"))
        # empty directory
        FileUtils.mkdir(dest_dir("quux"))
        FileUtils.mkdir(dest_dir(".git"))
        FileUtils.mkdir(dest_dir(".svn"))
        FileUtils.mkdir(dest_dir(".hg"))
        # single file in repository
        FileUtils.touch(dest_dir(".git/HEAD"))
        FileUtils.touch(dest_dir(".svn/HEAD"))
        FileUtils.touch(dest_dir(".hg/HEAD"))
      end

      teardown do
        FileUtils.rm_f(dest_dir("obsolete.html"))
        FileUtils.rm_rf(dest_dir("qux"))
        FileUtils.rm_f(dest_dir("quux"))
        FileUtils.rm_rf(dest_dir(".git"))
        FileUtils.rm_rf(dest_dir(".svn"))
        FileUtils.rm_rf(dest_dir(".hg"))
      end

      should "remove orphaned files in destination" do
        @site.process
        refute_exist dest_dir("obsolete.html")
        refute_exist dest_dir("qux")
        refute_exist dest_dir("quux")
        assert_exist dest_dir(".git")
        assert_exist dest_dir(".git", "HEAD")
      end

      should "remove orphaned files in destination - keep_files .svn" do
        config = site_configuration("keep_files" => %w(.svn))
        @site = Site.new(config)
        @site.process
        refute_exist dest_dir(".htpasswd")
        refute_exist dest_dir("obsolete.html")
        refute_exist dest_dir("qux")
        refute_exist dest_dir("quux")
        refute_exist dest_dir(".git")
        refute_exist dest_dir(".git", "HEAD")
        assert_exist dest_dir(".svn")
        assert_exist dest_dir(".svn", "HEAD")
      end
    end

    context "using a non-default markdown processor in the configuration" do
      should "use the non-default markdown processor" do
        class Bridgetown::Converters::Markdown::CustomMarkdown
          def initialize(*args)
            @args = args
          end

          def convert(*_args)
            ""
          end
        end

        custom_processor = "CustomMarkdown"
        s = Site.new(site_configuration("markdown" => custom_processor))
        s.process

        # Do some cleanup, we don't like straggling stuff.
        Bridgetown::Converters::Markdown.send(:remove_const, :CustomMarkdown)
      end

      should "ignore, if there are any bad characters in the class name" do
        module Bridgetown::Converters::Markdown::Custom
          class Markdown
            def initialize(*args)
              @args = args
            end

            def convert(*_args)
              ""
            end
          end
        end

        bad_processor = "Custom::Markdown"
        s = Site.new(site_configuration(
                       "markdown"    => bad_processor
                     ))
        assert_raises Bridgetown::Errors::FatalException do
          s.process
        end

        # Do some cleanup, we don't like straggling stuff.
        Bridgetown::Converters::Markdown.send(:remove_const, :Custom)
      end
    end

    context "with an invalid markdown processor in the configuration" do
      should "not throw an error at initialization time" do
        bad_processor = "not a processor name"
        assert Site.new(site_configuration("markdown" => bad_processor))
      end

      should "throw FatalException at process time" do
        bad_processor = "not a processor name"
        s = Site.new(site_configuration(
                       "markdown"    => bad_processor
                     ))
        assert_raises Bridgetown::Errors::FatalException do
          s.process
        end
      end
    end

    context "data directory" do
      should "auto load yaml files" do
        site = Site.new(site_configuration)
        site.process

        file_content = Bridgetown::YAMLParser.load_file(File.join(source_dir, "_data", "members.yaml"))

        assert_equal site.data["members"], file_content
        assert_equal site.site_payload["site"]["data"]["members"], file_content
      end

      should "auto load yml files" do
        site = Site.new(site_configuration)
        site.process

        file_content = Bridgetown::YAMLParser.load_file(File.join(source_dir, "_data", "languages.yml"))

        assert_equal site.data["languages"], file_content
        assert_equal site.site_payload["site"]["data"]["languages"], file_content
      end

      should "auto load json files" do
        site = Site.new(site_configuration)
        site.process

        file_content = Bridgetown::YAMLParser.load_file(File.join(source_dir, "_data", "members.json"))

        assert_equal site.data["members"], file_content
        assert_equal site.site_payload["site"]["data"]["members"], file_content
      end

      should "auto load yaml files in subdirectory" do
        site = Site.new(site_configuration)
        site.process

        file_content = Bridgetown::YAMLParser.load_file(File.join(
                                                          source_dir, "_data", "categories", "dairy.yaml"
                                                        ))

        assert_equal site.data["categories"]["dairy"], file_content
        assert_equal(
          site.site_payload["site"]["data"]["categories"]["dairy"],
          file_content
        )
      end

      should "load symlink files" do
        site = Site.new(site_configuration)
        site.process

        file_content = Bridgetown::YAMLParser.load_file(File.join(source_dir, "_data", "products.yml"))

        assert_equal site.data["products"], file_content
        assert_equal site.site_payload["site"]["data"]["products"], file_content
      end
    end

    context "manipulating the Bridgetown environment" do
      setup do
        ENV.delete("BRIDGETOWN_ENV")
        @site = Site.new(site_configuration)
        @site.process
        @page = @site.collections.pages.resources.find { |p| p.relative_path.basename.to_s == "environment.html" }
      end

      teardown do
        ENV["BRIDGETOWN_ENV"] = "test"
      end

      should "default to 'development'" do
        assert_equal "development", @page.content.strip
      end

      context "in production" do
        setup do
          ENV["BRIDGETOWN_ENV"] = "production"
          @site = Site.new(site_configuration)
          @site.process
          @page = @site.collections.pages.resources.find { |p| p.relative_path.basename.to_s == "environment.html" }
        end

        should "be overridden by BRIDGETOWN_ENV" do
          assert_equal "production", @page.content.strip
        end
      end
    end

    context "with liquid profiling" do
      setup do
        @site = Site.new(site_configuration("profile" => true))
      end

      # Suppress output while testing
      setup do
        $stdout = StringIO.new
      end
      teardown do
        $stdout = STDOUT
      end

      should "print profile table" do
        expect(@site.liquid_renderer).to receive(:stats_table)
        @site.process
      end
    end

    context "#in_cache_dir method" do
      setup do
        @site = Site.new(
          site_configuration(
            "cache_dir" => "../../custom-cache-dir"
          )
        )
      end

      should "create sanitized paths within the cache directory" do
        assert_equal File.join(@site.root_dir, "custom-cache-dir"), @site.cache_dir
        assert_equal(
          File.join(@site.root_dir, "custom-cache-dir", "foo.md.metadata"),
          @site.in_cache_dir("../../foo.md.metadata")
        )
      end
    end
  end
end
