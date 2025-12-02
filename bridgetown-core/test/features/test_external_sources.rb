# frozen_string_literal: true

require "features/feature_helper"

# Render content which lives in an external folder (outside of the site root)
class TestExternalSources < BridgetownFeatureTest
  describe "external_sources initializer" do
    it "renders ERB file" do
      sources_folder = File.expand_path("../external_sources_folder", __dir__)

      create_directory "config"
      create_file "config/initializers.rb", <<~RUBY
        Bridgetown.configure do |config|
          init :external_sources do
            contents do
              pages "#{sources_folder}"
            end
          end

          config.defaults << {
            scope: { collection: :pages },
            values: { layout: :simple },
          }
        end
      RUBY

      create_directory "_layouts"
      create_file "_layouts/simple.erb", "<head><title><%= data.title %></title></head><body><%= yield %></body>"

      _, output = run_bridgetown "build"

      expect(output).match?(%r{External Sources:.*bridgetown-core/test/external_sources_folder})

      assert_file_contains "This page lives outside of the root dir!", "output/subfolder/external_page/index.html"
      assert_file_contains "<head><title>Marked Down</title></head><body><h1 id=\"marked-down\">Marked Down</h1>\n\n<p>This is <strong>Markdown</strong> text. It’s as easy as 1, 2, 3!</p>\n",
                           "output/marked_down/index.html"
      refute_exist "output/.ignore"
    end
  end
end
