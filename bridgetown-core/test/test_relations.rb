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

    should "be accessible in Liquid loop" do
      page = @site.collections.pages.resources.find { |pg| pg.data.title == "I'm the Noodles index" }
      assert_includes page.output, "<li>Noodles!: /noodles/ramen/ (I'm a bløg pöst? 😄)"
    end
  end
end
