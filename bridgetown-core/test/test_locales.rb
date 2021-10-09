# frozen_string_literal: true

require "helper"

class TestLocales < BridgetownUnitTest
  context "similar pages in different locales" do
    setup do
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

    should "have the correct permalink and locale in English" do
      assert_equal "/second-level-page/", @english_resource.relative_url
      assert_includes @english_resource.output, "<p>Locale: en</p>"
    end

    should "have the correct permalink and locale in French" do
      assert_equal "/fr/second-level-page/", @french_resource.relative_url
      assert_includes @french_resource.output, "<p>C’est <strong>bien</strong>.</p>\n\n<p>Locale: fr</p>"
    end
  end

  context "one page which is generated into multiple locales" do
    setup do
      @site = resources_site
      @site.process
      # @type [Bridgetown::Resource::Base]
      @resources = @site.collections.pages.resources.select do |page|
        page.relative_path.to_s == "_pages/multi-page.md"
      end
      @english_resource = @resources.find { |page| page.data.locale == :en }
      @french_resource = @resources.find { |page| page.data.locale == :fr }
    end

    should "have the correct permalink and locale in English" do
      assert_equal "/multi-page/", @english_resource.relative_url
      assert_includes @english_resource.output, "<p>English: Multi-locale page</p>"
    end

    should "have the correct permalink and locale in French" do
      assert_equal "/fr/multi-page/", @french_resource.relative_url
      assert_includes @french_resource.output, "<p>French: Sur mesure</p>"
    end
  end
end
