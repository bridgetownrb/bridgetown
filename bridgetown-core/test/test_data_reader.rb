# frozen_string_literal: true

require "helper"

class TestDataReader < BridgetownUnitTest
  def setup
    @reader = DataReader.new(fixture_site)
  end

  context "#sanitize_filename" do
    should "remove evil characters" do
      assert_equal "helpwhathaveIdone", @reader.sanitize_filename(
        "help/what^&$^#*(!^%*!#haveId&&&&&&&&&one"
      )
    end
  end

  context "#merge_environment_specific_options!" do
    should "merge options in that are environment-specific" do
      @reader.instance_variable_set(:@content, {
        "site_metadata" => {
          "title"       => "Normal title",
          "development" => {
            "title" => "Development title",
          },
        },
      })
      metadata = @reader.content["site_metadata"]
      refute_equal "Development title", metadata["title"]
      @reader.merge_environment_specific_metadata!
      assert_equal "Development title", metadata["title"]
      assert_nil metadata["development"]
    end
  end

  context "access keys via HashWithIndifferentAccess" do
    should "work with JSON data files" do
      @reader.read("_data")
      assert_equal "John", @reader.content[:members][1][:name]
      assert_equal "John", @reader.content["members"][1]["name"]
    end
  end
end
