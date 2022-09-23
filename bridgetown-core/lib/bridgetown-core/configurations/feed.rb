# frozen_string_literal: true

say_status :feed, "Adding bridgetown-feed gem"

bundle_command = <<~BUNDLE
  bundle info bridgetown-feed ||
  bundle add bridgetown-feed -g bridgetown_plugins
BUNDLE

run bundle_command, { verbose: false, capture: true }

say_status :feed, "Adding feed tags"

head_file = Dir.glob("src/**/{head.liquid,_head.erb,_head.serb}").first

unless head_file
  say_status :feed, "Feed tags could not be automatically inserted"
  say_status :feed, "To enable, output `feed` in the application <head> element" \
                    "using the relevant template language tags"
  say ""
  say "For help with tag configuration see #{"https://github.com/bridgetownrb/bridgetown-feed#readme".yellow.bold}"

  return
end

File.open(head_file, "a+") do |file|
  feed_tag = Bridgetown::Utils.build_output_tag_for_template_extname(
    File.extname(head_file),
    "feed_meta"
  )

  file.write("#{feed_tag}\n") unless file.grep(%r{#{feed_tag}}).any?

  say ""
  say_status :feed, "Feed tags added to #{head_file}"
  say_status :feed, "For help with tag configuration see #{"https://github.com/bridgetownrb/bridgetown-feed#readme".yellow.bold}"
end
