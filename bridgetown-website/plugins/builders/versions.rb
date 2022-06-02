# frozen_string_literal: true

require "gems"

class Builders::Versions < SiteBuilder
  def self.cache
    @@cache
  end

  def build
    @@cache ||= Bridgetown::Cache.new("builders")

    helper :current_version_date do
      @@cache.getset("bridgetown-release-date") do
        versions = Gems.versions("bridgetown")
        version = versions.find { _1["number"] == Bridgetown::VERSION }&.dig("created_at")
        version ? Date.parse(version).strftime("%b %-d, %Y") : "(unknown)"
      end
    end

    hook :site, :post_read do
      if Bridgetown::VERSION.include?("alpha") || Bridgetown::VERSION.include?("beta")
        site.data.edge_version = true
        site.metadata.title += " [EDGE]"

        site.config.url = site.config.url.sub("www.", "edge.")
      end
    end
  end
end
