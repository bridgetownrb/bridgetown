Feature: WebpackPath Tag
  As a web developer who likes managing frontend assets with Webpack
  I want to be able to easily link JS and CSS output bundles using manifest.json
  So browsers don't use cached, out-of-date bundles

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
    And I have a ".bridgetown-webpack" directory
    And I have a ".bridgetown-webpack/manifest.json" file with content:
      """
      {
        "main.js": "all.hashgoeshere.js",
        "main.css": "all.hashgoeshere.css"
      }
      """
    When I run bridgetown build
    Then the "output/index.html" file should exist
    And I should see "/_bridgetown/static/js/all.hashgoeshere.js" in "output/index.html"
    And I should not see "//_bridgetown/static/js/all.hashgoeshere.js" in "output/index.html"
    And I should not see "MISSING_WEBPACK_MANIFEST" in "output/index.html"

  Scenario: Use custom filename in Webpack manifest
    Given I have a _layouts directory
    And I have a "_layouts/default.html" file with content:
      """
      <html>
      <head>
      <link rel="stylesheet" href="{% webpack_path css %}" />
      <link rel="preload" href="{% webpack_path images/folder/somefile.png %}" />
      </head>
      <body>
      {{ content }}
      </body>
      </html>
      """
    And I have an "index.html" page with layout "default" that contains "page content"
    And I have a ".bridgetown-webpack" directory
    And I have a ".bridgetown-webpack/manifest.json" file with content:
      """
      {
        "main.js": "all.hashgoeshere.js",
        "main.css": "all.hashgoeshere.css",
        "../frontend/images/folder/somefile.png": "../frontend/images/folder/somefile.hashgoeshere.png"
      }
      """
    When I run bridgetown build
    Then the "output/index.html" file should exist
    And I should see "/_bridgetown/static/frontend/images/folder/somefile.hashgoeshere.png" in "output/index.html"
    And I should not see "MISSING_WEBPACK_MANIFEST" in "output/index.html"

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
    When I run bridgetown build
    Then the "output/index.html" file should exist
    And I should see "MISSING_WEBPACK_MANIFEST" in "output/index.html"

  Scenario: Missing Webpack manifest
    Given I have a _layouts directory
    And I have a "_layouts/default.html" file with content:
      """
      <html>
      <head>
      <link rel="stylesheet" href="{% webpack_path bad %}" />
      </head>
      <body>
      {{ content }}
      </body>
      </html>
      """
    And I have an "index.html" page with layout "default" that contains "page content"
    And I have a ".bridgetown-webpack" directory
    And I have a ".bridgetown-webpack/manifest.json" file with content:
      """
      {
        "main.js": "all.hashgoeshere.js",
        "main.css": "all.hashgoeshere.css"
      }
      """
    When I run bridgetown build
    Then the "output/index.html" file should exist
    And I should see "Unknown Webpack asset type" in the build output

  Scenario: Broken Webpack manifest (css)
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
    And I have a ".bridgetown-webpack" directory
    And I have a ".bridgetown-webpack/manifest.json" file with content:
      """
      {
        "main.js": "all.hashgoeshere.js"
      }
      """
    When I run bridgetown build
    Then the "output/index.html" file should exist
    And I should see "WebpackAssetError" in the build output

  Scenario: Broken Webpack manifest (js)
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
    And I have a ".bridgetown-webpack" directory
    And I have a ".bridgetown-webpack/manifest.json" file with content:
      """
      {
        "main.css": "all.hashgoeshere.css"
      }
      """
    When I run bridgetown build
    Then the "output/index.html" file should exist
    And I should see "WebpackAssetError" in the build output

  Scenario: Use Webpack manifest in an ERB layout
    Given I have a _layouts directory
    And I have a "_layouts/default.erb" file with content:
      """
      <html>
      <head>
      <link rel="stylesheet" href="<%= webpack_path :css %>" />
      <script src="<%= webpack_path :js %>" defer></script>
      </head>
      <body>
      Static: <%= relative_url "_bridgetown" %>
      <%= yield %>
      </body>
      </html>
      """
    And I have an "index.html" page with layout "default" that contains "page content"
    And I have a ".bridgetown-webpack" directory
    And I have a ".bridgetown-webpack/manifest.json" file with content:
      """
      {
        "main.js": "all.hashgoeshere.js",
        "main.css": "all.hashgoeshere.css"
      }
      """
    When I run bridgetown build
    Then the "output/index.html" file should exist
    And I should see "/_bridgetown/static/js/all.hashgoeshere.js" in "output/index.html"
    And I should see "Static: /_bridgetown" in "output/index.html"
    And I should not see "MISSING_WEBPACK_MANIFEST" in "output/index.html"
