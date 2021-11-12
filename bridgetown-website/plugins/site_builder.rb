# frozen_string_literal: true

class SiteBuilder < Bridgetown::Builder
end

module ConsoleMethods
  def plugins_page
    collections.pages.resources.find { |page| page.relative_path.to_s.include?("plugins.serb") }
  end
end

Bridgetown::ConsoleMethods.include ConsoleMethods
