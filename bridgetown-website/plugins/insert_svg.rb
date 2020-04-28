# frozen_string_literal: true

module BridgetownSite
  class InsertSVGTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @text = text.gsub("../", "").strip
    end

    def render(context)
      svg_path = File.join(context.registers[:site].source, "images", @text)
      svg_lines = File.readlines(svg_path).map(&:strip).select do |line|
        line unless line.start_with?("<!", "<!--?xml")
      end
      svg_lines.join
    end
  end
end

Liquid::Template.register_tag("insert_svg", BridgetownSite::InsertSVGTag)
