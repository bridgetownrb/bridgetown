# frozen_string_literal: true

require "features/feature_helper"

# As a web developer who likes managing frontend assets with esbuild
# I want to be able to easily link JS and CSS output bundles using manifest.json
class TestAssetPathTag < BridgetownFeatureTest
  context "frontend manifest" do
    setup do
      create_directory "_layouts"
      create_page "index.html", "page content", layout: "default"
      create_file "esbuild.config.js", ""
      create_directory ".bridgetown-cache/frontend-bundling"
    end

    should "load for asset_tag" do
      create_file "_layouts/default.html", <<~HTML
        <html>
        <head>
        <link rel="stylesheet" href="{% asset_path css %}" />
        <script src="{% asset_path js %}" defer></script>
        </head>
        <body>
        {{ content }}
        </body>
        </html>
      HTML

      create_file ".bridgetown-cache/frontend-bundling/manifest.json", <<~JSON
        {
          "javascript/index.js": "all.hashgoeshere.js",
          "styles/index.css": "all.hashgoeshere.css"
        }
      JSON

      run_bridgetown "build"

      assert_file_contains %r!/_bridgetown/static/all.hashgoeshere.js!, "output/index.html"
      assert_file_contains %r!/_bridgetown/static/all.hashgoeshere.css!, "output/index.html"
      refute_file_contains %r!//_bridgetown/static/all.hashgoeshere.js!, "output/index.html"
      refute_file_contains %r!MISSING_FRONTEND_BUNDLING_CONFIG!, "output/index.html"
      refute_file_contains %r!MISSING_ESBUILD_ASSET!, "output/index.html"
    end

    should "provide custom files" do
      create_file "_layouts/default.html", <<~HTML
        <html>
        <head>
        <link rel="stylesheet" href="{% asset_path css %}" />
        <link rel="preload" href="{% asset_path images/folder/somefile.png %}" />
        </head>
        <body>
        {{ content }}
        </body>
        </html>
      HTML

      create_file ".bridgetown-cache/frontend-bundling/manifest.json", <<~JSON
        {
          "javascript/index.js": "all.hashgoeshere.js",
          "styles/index.css": "all.hashgoeshere.css",
          "images/folder/somefile.png": "somefile.hashgoeshere.png"
        }
      JSON

      run_bridgetown "build"

      assert_file_contains %r!/_bridgetown/static/somefile.hashgoeshere.png!, "output/index.html"
    end

    should "report when missing" do
      create_file "_layouts/default.html", <<~HTML
        <html>
        <head>
        <link rel="stylesheet" href="{% asset_path css %}" />
        <script src="{% asset_path js %}" defer></script>
        </head>
        <body>
        {{ content }}
        </body>
        </html>
      HTML

      FileUtils.rm("esbuild.config.js")
      run_bridgetown "build"

      assert_file_contains %r!"MISSING_FRONTEND_BUNDLING_CONFIG"!, "output/index.html"
    end

    should "handle missing asset files" do
      create_file "_layouts/default.html", <<~HTML
        <html>
        <head>
        <link rel="stylesheet" href="{% asset_path bad %}" />
        </head>
        <body>
        {{ content }}
        </body>
        </html>
      HTML

      create_file ".bridgetown-cache/frontend-bundling/manifest.json", <<~JSON
        {
          "javascript/index.js": "all.hashgoeshere.js",
          "styles/index.css": "all.hashgoeshere.css"
        }
      JSON

      _, output = run_bridgetown "build"

      # Check build output
      assert_includes output, "esbuild: The `bad' asset could not be found."
      assert_file_contains %r!"MISSING_ESBUILD_ASSET"!, "output/index.html"
    end

    should "work in ERB layouts" do
      # Scenario
      create_file "_layouts/default.erb", <<~HTML
        <html>
        <head>
        <link rel="stylesheet" href="<%= asset_path :css %>" />
        <script src="<%= asset_path :js %>" defer></script>
        </head>
        <body>
        Static: <%= relative_url "_bridgetown" %>
        <%= yield %>
        </body>
        </html>
      HTML

      create_file ".bridgetown-cache/frontend-bundling/manifest.json", <<~JSON
        {
          "javascript/index.js": "all.hashgoeshere.js",
          "styles/index.css": "all.hashgoeshere.css"
        }
      JSON

      run_bridgetown "build"

      assert_file_contains %r!/_bridgetown/static/all.hashgoeshere.js!, "output/index.html"
      assert_file_contains %r!/_bridgetown/static/all.hashgoeshere.css!, "output/index.html"
      assert_file_contains %r!Static: /_bridgetown!, "output/index.html"
      refute_file_contains %r!MISSING_FRONTEND_BUNDLING_CONFIG!, "output/index.html"
      refute_file_contains %r!MISSING_ESBUILD_ASSET!, "output/index.html"
    end
  end
end
