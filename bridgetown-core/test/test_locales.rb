# frozen_string_literal: true

require "helper"

class TestLocales < BridgetownUnitTest
  describe "similar pages in different locales as specified in filename" do
    before do
      reset_i18n_config
      @site = resources_site
      @site.process
      # @type [Bridgetown::Resource::Base]
      @english_resource = @site.collections.pages.resources.find do |page|
        page.relative_path.to_s == "_pages/second-level-page.en.md"
      end
      @french_resource = @site.collections.pages.resources.find do |page|
        page.relative_path.to_s == "_pages/second-level-page.fr.md"
      end
    end

    it "returns locales as symbols" do
      assert_equal :en, @english_resource.data.locale
      assert_equal :fr, @french_resource.data.locale
    end

    it "has the correct permalink and locale in English" do
      assert_equal "/second-level-page/", @english_resource.relative_url
      assert_includes @english_resource.output, "<title>I&#39;m a Second Level Page</title>"
      assert_includes @english_resource.output, "<p>Locale: en</p>"
    end

    it "has the correct permalink and locale in French" do
      assert_equal "/fr/second-level-page/", @french_resource.relative_url
      assert_includes @french_resource.output, "<title>I&#39;m a Second Level Page in French</title>"
      assert_includes @french_resource.output, "<p>C’est <strong>bien</strong>.</p>\n\n<p>Locale: fr</p>"

      assert_includes @french_resource.output, <<-HTML
    <li>I'm a Second Level Page: /second-level-page/</li>
    <li>I'm a Second Level Page in French: /fr/second-level-page/</li>
      HTML
    end
  end

  describe "one page which is generated into all available_locales" do
    before do
      reset_i18n_config
      @site = resources_site
      @site.process
      # @type [Bridgetown::Resource::Base]
      @resources = @site.collections.pages.resources.select do |page|
        page.relative_path.to_s == "_pages/multi-page.multi.md"
      end
      @english_resource = @resources.find { |page| page.data.locale == :en }
      @french_resource = @resources.find { |page| page.data.locale == :fr }
    end

    it "has the correct permalink and locale in English" do
      assert_equal "/multi-page/", @english_resource.relative_url
      assert_includes @english_resource.output, 'lang="en"'
      assert_includes @english_resource.output, "<title>Multi-locale page</title>"
      assert_includes @english_resource.output, "<p>English: Multi-locale page</p>"
    end

    it "has the correct permalink and locale in French" do
      assert_equal "/fr/multi-page/", @french_resource.relative_url
      assert_includes @french_resource.output, 'lang="fr"'
      assert_includes @french_resource.output, "<title>Sur mesure</title>"
      assert_includes @french_resource.output, "<p>French: Sur mesure</p>"

      assert_includes @french_resource.output, <<-HTML
    <li>Multi-locale page: /multi-page/</li>
    <li>Sur mesure: /fr/multi-page/</li>
      HTML
    end
  end

  describe "a page with a slug that matches others in this directory and also another directory" do
    before do
      @site = resources_site
      @site.process
      # @type [Bridgetown::Resource::Base]
      @resource = @site.collections.pages.resources.find do |page|
        page.relative_path.to_s == "_pages/my_directory/third-level-page.en.md"
      end

      @resource_with_matching_slug_in_same_directory = @site.collections.pages.resources.find do |page|
        page.relative_path.to_s == "_pages/my_directory/third-level-page.fr.md"
      end
    end

    describe "#all_locales" do
      it "lists only the resources with the same slug and the same parent directory" do
        assert_equal([@resource, @resource_with_matching_slug_in_same_directory], @resource.all_locales)
      end
    end
  end

  describe "one page which is generated into a subset of available_locales (as specified in locales key)" do
    before do
      reset_i18n_config
      @site = resources_site
      @site.process
      # @type [Bridgetown::Resource::Base]
      @resources = @site.collections.pages.resources.select do |page|
        page.relative_path.to_s == "_pages/multi-page-with-specified-locales.multi.md"
      end
      @english_resource = @resources.find { |page| page.data.locale == :en }
    end

    it "has the correct permalink and locale in English" do
      assert_equal "/multi-page-with-specified-locales/", @english_resource.relative_url
      assert_includes @english_resource.output, 'lang="en"'
      assert_includes @english_resource.output, "<title>Multi-locale with specified locales page</title>"
      assert_includes @english_resource.output, "<p>English: Multi-locale with specified locales page</p>"
    end

    it "does not have generated any locales other than English" do
      assert_equal 1, @resources.length
    end
  end

  describe "locales and a base_path combined" do
    before do
      reset_i18n_config
      @site = resources_site(base_path: "/basefolder")
      @site.process
      # @type [Bridgetown::Resource::Base]
      @resources = @site.collections.pages.resources.select do |page|
        page.relative_path.to_s == "_pages/multi-page.multi.md"
      end
      @english_resource = @resources.find { |page| page.data.locale == :en }
      @french_resource = @resources.find { |page| page.data.locale == :fr }
    end

    it "has the correct permalink and locale in English" do
      assert_equal "/basefolder/multi-page/", @english_resource.relative_url
      assert_includes @english_resource.output, 'lang="en"'
      assert_includes @english_resource.output, "<title>Multi-locale page</title>"
      assert_includes @english_resource.output, "<p>English: Multi-locale page</p>"
    end

    it "has the correct permalink and locale in French" do
      assert_equal "/basefolder/fr/multi-page/", @french_resource.relative_url
      assert_includes @french_resource.output, 'lang="fr"'
      assert_includes @french_resource.output, "<title>Sur mesure</title>"
      assert_includes @french_resource.output, "<p>French: Sur mesure</p>"

      assert_includes @french_resource.output, <<-HTML
    <li>Multi-locale page: /basefolder/multi-page/</li>
    <li>Sur mesure: /basefolder/fr/multi-page/</li>
      HTML
    end
  end

  describe "locales, prefix_default_locale, and base_path combined" do
    before do
      reset_i18n_config
      @site = resources_site(base_path: "/basefolder", prefix_default_locale: true)
      @site.process
      # @type [Bridgetown::Resource::Base]
      @resources = @site.collections.pages.resources.select do |page|
        page.relative_path.to_s == "_pages/multi-page.multi.md"
      end
      @english_resource = @resources.find { |page| page.data.locale == :en }
      @french_resource = @resources.find { |page| page.data.locale == :fr }
    end

    it "has the correct permalink and locale in English" do
      assert_equal "/basefolder/en/multi-page/", @english_resource.relative_url
      assert_includes @english_resource.output, 'lang="en"'
      assert_includes @english_resource.output, "<title>Multi-locale page</title>"
      assert_includes @english_resource.output, "<p>English: Multi-locale page</p>"
    end

    it "has the correct permalink and locale in French" do
      assert_equal "/basefolder/fr/multi-page/", @french_resource.relative_url
      assert_includes @french_resource.output, 'lang="fr"'
      assert_includes @french_resource.output, "<title>Sur mesure</title>"
      assert_includes @french_resource.output, "<p>French: Sur mesure</p>"

      assert_includes @french_resource.output, <<-HTML
    <li>Multi-locale page: /basefolder/en/multi-page/</li>
    <li>Sur mesure: /basefolder/fr/multi-page/</li>
      HTML
    end

    describe "translation filters" do
      before do
        reset_i18n_config
        @site = resources_site
        @site.process
        # @type [Bridgetown::Resource::Base]
        @resources = @site.collections.pages.resources.select do |page|
          page.relative_path.to_s == "_pages/multi-page.multi.md"
        end
        @english_resource = @resources.find { |page| page.data.locale == :en }
        @french_resource = @resources.find { |page| page.data.locale == :fr }
      end

      it "pulls in the right English translation" do
        assert_includes @english_resource.output, "<p>English: Test Name</p>"
      end

      it "falls back to English on missing translation" do
        assert_includes @french_resource.output, "<p>Français: Test Name</p>"
      end
    end
  end

  describe "fallback chain" do
    before do
      reset_i18n_config
      @site = resources_site
      @site.process
    end

    it "includes English for base language" do
      assert_equal %i[de en], I18n.fallbacks[:de]
      assert_equal %i[fr en], I18n.fallbacks[:fr]
    end

    it "includes English and base language for regional locale" do
      assert_equal %i[de-NL de en], I18n.fallbacks[:"de-NL"]
      assert_equal %i[fr-CA fr en], I18n.fallbacks[:"fr-CA"]
    end
  end

  describe "fallback chain with different default locale" do
    before do
      reset_i18n_config
      @site = resources_site("default_locale" => :es, "available_locales" => %w[en es])
      @site.process
    end

    it "includes both the default language and English in the fallback chain" do
      assert_equal %i[de es en], I18n.fallbacks[:de]
      assert_equal %i[es en], I18n.fallbacks[:es]
    end

    it "includes base language, default, and English for regional language" do
      assert_equal %i[de-NL de es en], I18n.fallbacks[:"de-NL"]
      assert_equal %i[es-MX es en], I18n.fallbacks[:"es-MX"]
    end
  end
end
