module BridgetownSite
  class InsertSVGTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @text = text.gsub("../","").strip
    end

    def render(context)
      svg_path = File.join(context.registers[:site].source, "images", @text)
      File.read(svg_path).strip
    end
  end
end

Liquid::Template.register_tag('insert_svg', BridgetownSite::InsertSVGTag)
