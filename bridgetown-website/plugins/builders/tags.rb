# frozen_string_literal: true

class TagsBuilder < SiteBuilder
  def build
    liquid_tag "toc" do
      <<~TAG
        ## Table of Contents
        {:.no_toc}
        * …
        {:toc}
      TAG
    end

    liquid_tag "insert_svg" do |filename|
      svg_path = File.join site.source, "images", filename.gsub("../", "")
      svg_lines = File.readlines(svg_path).map(&:strip).select do |line|
        line unless line.start_with?("<!", "<?xml")
      end
      svg_lines.join
    end
  end
end
