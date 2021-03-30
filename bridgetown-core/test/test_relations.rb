# frozen_string_literal: true

require "helper"

class TestRelations < BridgetownUnitTest
  context "belongs_to and has_many" do
    setup do
      @site = resources_site({
        "collections" => {
          "noodles" => {
            "output"    => true,
            "relations" => {
              "has_many" => "posts",
            },
          },
          "posts"   => {
            "relations" => {
              "belongs_to" => "noodle",
            },
          },
        },
      })
      @site.process
      # @type [Bridgetown::Resource::Base]
      @resource = @site.collections.posts.resources[0]
    end

    should "exist" do
      assert !@resource.nil?
    end

    should "post belongs to noodle" do
      assert_equal "Noodles!", @resource.relations.noodle.data.title
    end

    should "noodle has many posts" do
      assert_equal "I'm a bløg pöst? 😄", @resource.relations.noodle.relations.posts.first.data.title
    end
  end
end
