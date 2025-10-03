# frozen_string_literal: true

say_status :seo, "Adding bridgetown-seo-tag gem..."

add_gem "bridgetown-seo-tag"
add_initializer :"bridgetown-seo-tag"

head_file = Dir.glob("src/**/{head.liquid,_head.erb,_head.serb}").first

unless head_file
  say_status :seo, "SEO tags could not be automatically inserted"
  say_status :seo, "To enable SEO, output `seo` in the application <head> element" \
                   "using the relevant template language tags"
  say "For further reading, check out " \
      '"https://github.com/bridgetownrb/bridgetown-seo-tag#readme"', :blue

  return
end

say_status :seo, "Adding SEO tags to #{head_file}..."

seo_tag = Bridgetown::Utils.helper_code_for_template_extname(
  File.extname(head_file),
  "seo"
)

File.open(head_file, "a+") do |file|
  file.write("#{seo_tag}\n") unless file.grep(%r{#{seo_tag}}).any?
end

say_status :seo, "bridgetown-seo-tag is now configured!"
say "For further reading, check out " \
    '"https://github.com/bridgetownrb/bridgetown-seo-tag#readme"', :blue
