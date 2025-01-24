# frozen_string_literal: true

require "features/feature_helper"

class TestPluginsCommand < BridgetownFeatureTest
  describe "list registered plugins" do
    before do
      create_directory "config"
      create_file "config/initializers.rb", <<~RUBY
        Bridgetown.configure do |config|
        end
      RUBY
    end

    it "excludes init (Initializer) from registered plugins list" do
      _, output = run_bridgetown "plugins", "list", trace: false
      output = Bridgetown::Foundation::Packages::Ansi.strip(output)

      refute_includes output, "init (Initializer)"
      assert_includes output, "Registered Plugins: 5"
    end
  end
end
