# frozen_string_literal: true

class Builders::Tags < SiteBuilder
  def build
    liquid_tag "toc", :toc_template
    helper "toc", :toc_template
  end

  def toc_template(_attributes = nil, _tag = nil)
    <<~TAG
      ## Table of Contents
      {:.no_toc}
      * …
      {:toc}
    TAG
  end
end
