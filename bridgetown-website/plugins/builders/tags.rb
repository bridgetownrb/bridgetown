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
  end
end
