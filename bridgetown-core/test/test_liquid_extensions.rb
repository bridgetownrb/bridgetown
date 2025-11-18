# frozen_string_literal: true

require "helper"

class TestLiquidExtensions < BridgetownUnitTest
  describe "looking up a variable in a Liquid context" do
    class SayHi < Liquid::Tag
      include Bridgetown::LiquidExtensions

      def initialize(_tag_name, markup, _tokens)
        @markup = markup.strip
      end

      def render(context)
        "hi #{lookup_variable(context, @markup)}"
      end
    end
    Liquid::Template.register_tag("say_hi", SayHi)
    before do
      # Parses and compiles the template
      @template = Liquid::Template.parse("{% say_hi page.name %}")
    end

    it "extracts the var properly" do
      assert_equal "hi tobi", @template.render("page" => { "name" => "tobi" })
    end

    it "returns the variable name if the value isn't there" do
      assert_equal "hi page.name", @template.render("page" => { "title" => "tobi" })
    end
  end
end
