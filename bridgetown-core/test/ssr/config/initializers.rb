# frozen_string_literal: true

Bridgetown.configure do
  # attempt multiple inits just to ensure it is idempotent
  init :local_ssr_init, require_gem: false
  init :local_ssr_init, require_gem: false
  init :local_ssr_init, require_gem: false

  collections do
    posts do
      skip_for_ssr true
    end
  end

  # poor man's Inspector plugin
  hook :resources, :post_render do |resource|
    next unless resource.site.root_dir.end_with?("test/ssr") # ugly hack or else test suite errors

    document = Nokogiri.HTML5(resource.output)
    document.css("p.test").each do |paragraph|
      paragraph.inner_html = paragraph.inner_html.upcase
    end
    resource.output = document.to_html
  end
end
