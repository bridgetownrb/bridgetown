# frozen_string_literal: true

require "helper"

class TestDefaultsReader < BridgetownUnitTest
  def setup
    @reader = DefaultsReader.new(fixture_site)
    @reader.read
  end

  describe "default files" do
    it "is loaded" do
      assert_equal "groovy", @reader.path_defaults["#{fixture_site.source}/_posts/"][:ruby3]
      assert_equal "trippin", @reader.path_defaults["#{fixture_site.source}/_posts/es/"][:ruby3]
    end
  end
end
