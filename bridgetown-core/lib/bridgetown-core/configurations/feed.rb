# frozen_string_literal: true

say_status :feed, "Adding bridgetown-feed gem..."

add_gem "bridgetown-feed"
add_initializer :"bridgetown-feed"

head_file = Dir.glob("src/**/{head.liquid,_head.erb,_head.serb}").first

unless head_file
  say_status :feed, "Feed tags could not be automatically inserted"
  say_status :feed, "To enable, output `feed` in the application <head> element" \
                    "using the relevant template language tags"
  say "For further reading, check out " \
      '"https://github.com/bridgetownrb/bridgetown-feed#readme"', :blue

  return
end

say_status :feed, "Adding feed tags to #{head_file}..."

feed_tag = Bridgetown::Utils.build_output_tag_for_template_extname(
  File.extname(head_file),
  "feed_meta"
)

File.open(head_file, "a+") do |file|
  file.write("#{feed_tag}\n") unless file.grep(%r{#{feed_tag}}).any?
end

say_status :feed, "bridgetown-feed is now configured!"
say "For further reading, check out " \
    '"https://github.com/bridgetownrb/bridgetown-feed#readme"', :blue
