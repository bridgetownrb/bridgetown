Feature: AssetPath Tag
  As a web developer who likes managing frontend assets with Webpack or esbuild
  I want to be able to easily link JS and CSS output bundles using manifest.json
  So browsers don't use cached, out-of-date bundles

  Scenario: Use frontend manifest
    Given I have a _layouts directory
    And I have a "_layouts/default.html" file with content:
      """
      <html>
      <head>
      <link rel="stylesheet" href="{% asset_path css %}" />
      <script src="{% asset_path js %}" defer></script>
      </head>
      <body>
      {{ content }}
      </body>
      </html>
      """
    And I have an "index.html" page with layout "default" that contains "page content"
    And I have a "esbuild.config.js" file with content:
      """
      """
    And I have a ".bridgetown-cache/frontend-bundling" directory
    And I have a ".bridgetown-cache/frontend-bundling/manifest.json" file with content:
      """
      {
        "javascript/index.js": "all.hashgoeshere.js",
        "styles/index.css": "all.hashgoeshere.css"
      }
      """
    When I run bridgetown build
    Then the "output/index.html" file should exist
    And I should see "/_bridgetown/static/all.hashgoeshere.js" in "output/index.html"
    And I should see "/_bridgetown/static/all.hashgoeshere.css" in "output/index.html"
    And I should not see "//_bridgetown/static/all.hashgoeshere.js" in "output/index.html"
    And I should not see "MISSING_FRONTEND_BUNDLING_CONFIG" in "output/index.html"
    And I should not see "MISSING_ESBUILD_ASSET" in "output/index.html"

  Scenario: Use custom filename in frontend manifest
    Given I have a _layouts directory
    And I have a "_layouts/default.html" file with content:
      """
      <html>
      <head>
      <link rel="stylesheet" href="{% asset_path css %}" />
      <link rel="preload" href="{% asset_path images/folder/somefile.png %}" />
      </head>
      <body>
      {{ content }}
      </body>
      </html>
      """
    And I have an "index.html" page with layout "default" that contains "page content"
    And I have a "esbuild.config.js" file with content:
      """
      """
    And I have a ".bridgetown-cache/frontend-bundling" directory
    And I have a ".bridgetown-cache/frontend-bundling/manifest.json" file with content:
      """
      {
        "javascript/index.js": "all.hashgoeshere.js",
        "styles/index.css": "all.hashgoeshere.css",
        "images/folder/somefile.png": "somefile.hashgoeshere.png"
      }
      """
    When I run bridgetown build
    Then the "output/index.html" file should exist
    And I should see "/_bridgetown/static/somefile.hashgoeshere.png" in "output/index.html"

  Scenario: Missing frontend manifest
    Given I have a _layouts directory
    And I have a "_layouts/default.html" file with content:
      """
      <html>
      <head>
      <link rel="stylesheet" href="{% asset_path css %}" />
      <script src="{% asset_path js %}" defer></script>
      </head>
      <body>
      {{ content }}
      </body>
      </html>
      """
    And I have an "index.html" page with layout "default" that contains "page content"
    When I run bridgetown build
    Then the "output/index.html" file should exist
    And I should see "MISSING_FRONTEND_BUNDLING_CONFIG" in "output/index.html"

  Scenario: Missing asset file
    Given I have a _layouts directory
    And I have a "_layouts/default.html" file with content:
      """
      <html>
      <head>
      <link rel="stylesheet" href="{% asset_path bad %}" />
      </head>
      <body>
      {{ content }}
      </body>
      </html>
      """
    And I have an "index.html" page with layout "default" that contains "page content"
    And I have a "esbuild.config.js" file with content:
      """
      """
    And I have a ".bridgetown-cache/frontend-bundling" directory
    And I have a ".bridgetown-cache/frontend-bundling/manifest.json" file with content:
      """
      {
        "javascript/index.js": "all.hashgoeshere.js",
        "styles/index.css": "all.hashgoeshere.css"
      }
      """
    When I run bridgetown build
    Then the "output/index.html" file should exist
    And I should see "esbuild:" in the build output

  Scenario: Broken frontend manifest (css)
    Given I have a _layouts directory
    And I have a "_layouts/default.html" file with content:
      """
      <html>
      <head>
      <link rel="stylesheet" href="{% asset_path css %}" />
      <script src="{% asset_path js %}" defer></script>
      </head>
      <body>
      {{ content }}
      </body>
      </html>
      """
    And I have an "index.html" page with layout "default" that contains "page content"
    And I have a "esbuild.config.js" file with content:
      """
      """
    And I have a ".bridgetown-cache/frontend-bundling" directory
    And I have a ".bridgetown-cache/frontend-bundling/manifest.json" file with content:
      """
      {
        "javascript/index.js": "all.hashgoeshere.js"
      }
      """
    When I run bridgetown build
    Then the "output/index.html" file should exist
    And I should see "esbuild:" in the build output

  Scenario: Broken frontend manifest (js)
    Given I have a _layouts directory
    And I have a "_layouts/default.html" file with content:
      """
      <html>
      <head>
      <link rel="stylesheet" href="{% asset_path css %}" />
      <script src="{% asset_path js %}" defer></script>
      </head>
      <body>
      {{ content }}
      </body>
      </html>
      """
    And I have an "index.html" page with layout "default" that contains "page content"
    And I have a "esbuild.config.js" file with content:
      """
      """
    And I have a ".bridgetown-cache/frontend-bundling" directory
    And I have a ".bridgetown-cache/frontend-bundling/manifest.json" file with content:
      """
      {
        "styles/index.css": "all.hashgoeshere.css"
      }
      """
    When I run bridgetown build
    Then the "output/index.html" file should exist
    And I should see "esbuild:" in the build output

  Scenario: Use frontend manifest in an ERB layout
    Given I have a _layouts directory
    And I have a "_layouts/default.erb" file with content:
      """
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
      """
    And I have an "index.html" page with layout "default" that contains "page content"
    And I have a "esbuild.config.js" file with content:
      """
      """
    And I have a ".bridgetown-cache/frontend-bundling" directory
    And I have a ".bridgetown-cache/frontend-bundling/manifest.json" file with content:
      """
      {
        "javascript/index.js": "all.hashgoeshere.js",
        "styles/index.css": "all.hashgoeshere.css"
      }
      """
    When I run bridgetown build
    Then the "output/index.html" file should exist
    And I should see "/_bridgetown/static/all.hashgoeshere.js" in "output/index.html"
    And I should see "Static: /_bridgetown" in "output/index.html"
    And I should not see "MISSING_FRONTEND_BUNDLING_CONFIG" in "output/index.html"

  Scenario: Use Webpack manifest
    Given I have a _layouts directory
    And I have a "_layouts/default.html" file with content:
      """
      <html>
      <head>
      <link rel="stylesheet" href="{% webpack_path css %}" />
      <script src="{% webpack_path js %}" defer></script>
      </head>
      <body>
      {{ content }}
      </body>
      </html>
      """
    And I have an "index.html" page with layout "default" that contains "page content"
    And I have a "webpack.config.js" file with content:
      """
      """
    And I have a ".bridgetown-cache/frontend-bundling" directory
    And I have a ".bridgetown-cache/frontend-bundling/manifest.json" file with content:
      """
      {
        "main.js": "all.hashgoeshere.js",
        "main.css": "../css/all.hashgoeshere.css"
      }
      """
    When I run bridgetown build
    Then the "output/index.html" file should exist
    And I should see "/_bridgetown/static/js/all.hashgoeshere.js" in "output/index.html"
    And I should see "/_bridgetown/static/css/all.hashgoeshere.css" in "output/index.html"
    And I should not see "//_bridgetown/static/js/all.hashgoeshere.js" in "output/index.html"
    And I should not see "MISSING_WEBPACK_ASSET" in "output/index.html"

  Scenario: Missing Webpack manifest
    Given I have a _layouts directory
    And I have a "_layouts/default.html" file with content:
      """
      <html>
      <head>
      <link rel="stylesheet" href="{% webpack_path css %}" />
      <script src="{% webpack_path js %}" defer></script>
      </head>
      <body>
      {{ content }}
      </body>
      </html>
      """
    And I have an "index.html" page with layout "default" that contains "page content"
    And I have a "webpack.config.js" file with content:
      """
      """
    When I run bridgetown build
    Then the "output/index.html" file should exist
    And I should see "MISSING_WEBPACK_ASSET" in "output/index.html"