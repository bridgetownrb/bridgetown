# frozen_string_literal: true

class Builders::EdgeVersions < SiteBuilder
  def build
    hook :site, :post_read do
      if Bridgetown::VERSION.include?("alpha") || Bridgetown::VERSION.include?("beta")
        site.data.edge_version = true
      end
    end
  end
end
