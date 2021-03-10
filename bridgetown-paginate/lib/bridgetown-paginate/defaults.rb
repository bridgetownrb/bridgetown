# frozen_string_literal: true

module Bridgetown
  module Paginate
    # The default configuration for the Paginator
    DEFAULT = {
      "offset"       => 0, # Supports skipping x number of posts from the
      # beginning of the post list
      "per_page"     => 10,
      "permalink"    => "/page/:num/", # Supports :num as customizable elements
      "title"        => ":title (Page :num)", # Supports :num as customizable elements
      "page_num"     => 1,
      "sort_reverse" => true,
      "sort_field"   => "date",
      "limit"        => 0, # Limit how many content objects to paginate (default: 0, means all)
      "trail"        => {
        "before" => 0, # Limits how many links to show before the current page
        # in the pagination trail (0, means off, default: 0)
        "after"  => 0, # Limits how many links to show after the current page
        # in the pagination trail (0 means off, default: 0)
      },
      "indexpage"    => nil, # The default name of the index pages
      "extension"    => "html", # The default extension for the output pages
      # (ignored if indexpage is nil)
      "debug"        => false, # Turns on debug output for the gem
    }.freeze
  end
end
