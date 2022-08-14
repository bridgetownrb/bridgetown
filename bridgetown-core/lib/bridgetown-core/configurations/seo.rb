# frozen_string_literal: true

say_status :seo, "Adding bridgetown-seo-tag gem"

bundle_command = <<~BUNDLE
  bundle info bridgetown-seo-tag ||
  bundle add bridgetown-seo-tag -g bridgetown_plugins
BUNDLE

run bundle_command, { verbose: false, capture: true }

say_status :seo, "Adding SEO tags"

head_file = Dir.glob("src/**/{head.liquid,_head.erb,_head.serb}").first

unless head_file
  say_status :seo, "SEO tags could not be automatically inserted"
  say_status :seo, "To enable SEO, output `seo` in the application <head> element" \
                   "using the relevant template language tags"
  say ""
  say "For help with tag configuration see #{"https://github.com/bridgetownrb/bridgetown-seo-tag#readme".yellow.bold}"

  return
end

File.open(head_file, "a+") do |file|
  seo_tag = Bridgetown::Utils.build_output_tag_for_template_extname(File.extname(head_file), "seo")

  file.write("#{seo_tag}\n") unless file.grep(%r{#{seo_tag}}).any?

  say ""
  say_status :seo, "SEO tags added to #{head_file}"
  say_status :seo, "For help with tag configuration see #{"https://github.com/bridgetownrb/bridgetown-seo-tag#readme".yellow.bold}"
end
