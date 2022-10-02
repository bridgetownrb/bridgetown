# frozen_string_literal: true

require "helper"

class TagsBuilder < Builder
  def build
    liquid_tag "testing_tags" do |attributes|
      attr = attributes.split(":")[1]
      "output of the tag #{attr}"
    end

    liquid_tag :upcase_tag, as_block: true do |_attributes, tag|
      tag.content.upcase
    end

    liquid_tag "testing_context" do |_attributes, tag|
      "context value #{tag.context.registers[:value]}, #{tag.context["yay"]}"
    end
  end
end

class TestTagsDSL < BridgetownUnitTest
  context "adding a Liquid tag" do
    setup do
      @site = Site.new(site_configuration)
      @builder = TagsBuilder.new("TagsDSL", @site).build_with_callbacks
    end

    should "output the right tag" do
      content = "This is the {% testing_tags name:test %}"
      result = Liquid::Template.parse(content).render
      assert_equal "This is the output of the tag test", result
    end

    should "work with block tags" do
      content = "This is the {% upcase_tag %}upcase{% endupcase_tag %} tag"
      result = Liquid::Template.parse(content).render
      assert_equal "This is the UPCASE tag", result
    end

    should "provide context access" do
      content = "This is the {% testing_context %}"
      result = Liquid::Template.parse(content).render({ "yay" => "yay!" },
                                                      registers: { value: 123 })
      assert_equal "This is the context value 123, yay!", result
    end
  end
end
