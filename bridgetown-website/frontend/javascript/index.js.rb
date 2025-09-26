import "@awesome.me/webawesome/dist/styles/themes/default.css"
#import "@awesome.me/webawesome/dist/styles/utilities.css"
#import "@awesome.me/webawesome/dist/themes/dark.css"
import "@awesome.me/webawesome/dist/components/avatar/avatar.js"
import "@awesome.me/webawesome/dist/components/breadcrumb/breadcrumb.js"
import "@awesome.me/webawesome/dist/components/breadcrumb-item/breadcrumb-item.js"
import "@awesome.me/webawesome/dist/components/button/button.js"
import "@awesome.me/webawesome/dist/components/callout/callout.js"
import "@awesome.me/webawesome/dist/components/card/card.js"
import "@awesome.me/webawesome/dist/components/dialog/dialog.js"
import "@awesome.me/webawesome/dist/components/divider/divider.js";
import "@awesome.me/webawesome/dist/components/dropdown/dropdown.js"
import "@awesome.me/webawesome/dist/components/icon/icon.js"
import "@awesome.me/webawesome/dist/components/input/input.js"
# import "@awesome.me/webawesome/dist/components/menu/menu.js"
# import "@awesome.me/webawesome/dist/components/menu-item/menu-item.js"
import "@awesome.me/webawesome/dist/components/tab-group/tab-group.js"
import "@awesome.me/webawesome/dist/components/tab-panel/tab-panel.js"
import "@awesome.me/webawesome/dist/components/tab/tab.js";
import "@awesome.me/webawesome/dist/components/tag/tag.js"
import [ register_icon_library ], from: "@awesome.me/webawesome/dist/webawesome.js"
#import [ set_base_path ], from: "@awesome.me/webawesome/dist/utilities/base-path.js"
#import [ set_animation ], from: "@awesome.me/webawesome/dist/utilities/animation-registry.js"

import "*", as: Turbo, from: "@hotwired/turbo"

import hotkeys from "hotkeys-js"
hotkeys "cmd+k,ctrl+k" do |event|
  event.prevent_default()
  document.query_selector("bridgetown-search-form > input").focus()
end

import "./turbo_transitions.js.rb"

async def import_additional_dependencies()
  await import("bridgetown-quick-search")

  document.query_selector("bridgetown-search-form > input").add_event_listener :keydown do |event|
    if event.key_code == 13
      document.query_selector("bridgetown-search-results").show_results_for_query(event.target.value)
    end

    event.target.closest("bt-bar-item").query_selector("kbd").style.display = "none"
  end

  await import("./wiggle_note.js.rb")
  await import("./theme_picker.js.rb")
end

import_additional_dependencies()

import "$styles/index.css"

import components from "bridgetownComponents/**/*.{js,jsx,js.rb,css}"
Object.entries(components)

register_icon_library('remixicon',
  resolver: -> name do
    match = name.match(/^(.*?)\/(.*?)(-(fill))?$/)
    match[1] = match[1].char_at(0).upcase() + match[1].slice(1)
    "https://cdn.jsdelivr.net/npm/remixicon@3.3.0/icons/#{match[1]}/#{match[2]}#{match[3] || '-line'}.svg";
  end,
  mutator: -> svg { svg.set_attribute('fill', 'currentColor') }
)

#set_base_path "/images"

# This is weird, I'm not sure why I have to do this.
document.add_event_listener "turbo:load" do
  document.query_selector_all("wa-button").each do |button|
    if button.parent_node.local_name == :a
      button.add_event_listener :click do |event|
        event.prevent_default()
        Turbo.visit event.current_target.parent_node.href
      end
    end
  end
end
