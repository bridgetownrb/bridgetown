# frozen_string_literal: true

require "features/feature_helper"

# I want to be able to cache certain aspects across multiple builds
# And retrieve the cached aspects when needed
class TestCache < BridgetownFeatureTest
  context "cache folder" do
    should "exist after build" do
      create_page "index.md", "{{ data.title }}", title: "Hello World"

      run_bridgetown "build"

      assert_exist ".bridgetown-cache"
      assert_exist ".bridgetown-cache/Bridgetown/Cache/Bridgetown--Cache"
      assert_file_contains "<p>Hello World</p>", "output/index.html"
    end

    should "support custom cache configuration" do
      create_page "index.md", "{{ data.title }}", title: "Hello World"

      create_configuration cache_dir: ".foo-cache"
      run_bridgetown "build"

      refute_exist ".bridgetown-cache"
      assert_exist ".foo-cache"
      assert_exist ".foo-cache/Bridgetown/Cache/Bridgetown--Cache"
      assert_file_contains "<p>Hello World</p>", "output/index.html"
    end

    should "not exist after build with CLI flag" do
      create_page "index.md", "{{ data.title }}", title: "Hello World"

      run_bridgetown "build", "--disable-disk-cache"

      refute_exist ".bridgetown-cache"
      assert_file_contains "<p>Hello World</p>", "output/index.html"
    end
  end
end
