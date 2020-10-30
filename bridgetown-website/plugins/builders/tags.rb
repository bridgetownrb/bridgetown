# frozen_string_literal: true

class TagsBuilder < SiteBuilder
  def build
    liquid_tag "toc", :toc_template
    helper "toc", :toc_template
  end

  def toc_template(attributes=nil, tag=nil)
    <<~TAG
      ## Table of Contents
      {:.no_toc}
      * …
      {:toc}
    TAG
  end
end
