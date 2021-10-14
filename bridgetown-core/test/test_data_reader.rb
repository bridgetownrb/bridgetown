# frozen_string_literal: true

require "helper"

class TestDataReader < BridgetownUnitTest
  # TODO: test resource data reading instead...some of that is already in the test_resource.rb file

  # def setup
  #   @reader = DataReader.new(fixture_site)
  # end

  # context "#sanitize_filename" do
  #   should "remove evil characters" do
  #     assert_equal "helpwhathaveIdone", @reader.sanitize_filename(
  #       "help/what^&$^#*(!^%*!#haveId&&&&&&&&&one"
  #     )
  #   end
  # end

  # context "#merge_environment_specific_options!" do
  #   should "merge options in that are environment-specific" do
  #     @reader.instance_variable_set(:@content, {
  #       "site_metadata" => {
  #         "title" => "Normal title",
  #         "test"  => {
  #           "title" => "Test title",
  #         },
  #       },
  #     }.with_dot_access)
  #     metadata = @reader.content[:site_metadata]
  #     refute_equal "Test title", metadata[:title]
  #     @reader.merge_environment_specific_metadata!
  #     assert_equal "Test title", metadata[:title]
  #     assert_nil metadata[:test]
  #   end
  # end

  # context "access keys via HashWithDotAccess" do
  #   should "work with JSON data files" do
  #     @reader.read
  #     assert_equal "John", @reader.content[:members][1][:name]
  #     assert_equal "John", @reader.content["members"][1]["name"]
  #     assert_equal "John", @reader.content.members[1].name
  #   end
  # end
end
