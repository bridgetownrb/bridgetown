import '@shoelace-style/shoelace/dist/themes/light.css'
import '@shoelace-style/shoelace/dist/components/alert/alert.js'
import '@shoelace-style/shoelace/dist/components/avatar/avatar.js'
import '@shoelace-style/shoelace/dist/components/breadcrumb/breadcrumb.js'
import '@shoelace-style/shoelace/dist/components/breadcrumb-item/breadcrumb-item.js'
import '@shoelace-style/shoelace/dist/components/button/button.js'
import '@shoelace-style/shoelace/dist/components/card/card.js'
import '@shoelace-style/shoelace/dist/components/dialog/dialog.js'
import '@shoelace-style/shoelace/dist/components/form/form.js'
import '@shoelace-style/shoelace/dist/components/icon/icon.js'
import '@shoelace-style/shoelace/dist/components/input/input.js'
import '@shoelace-style/shoelace/dist/components/tag/tag.js'
import [ register_icon_library ], from: '@shoelace-style/shoelace/dist/utilities/icon-library.js'
import [ set_animation ], from: '@shoelace-style/shoelace/dist/utilities/animation-registry.js'

import "*", as: Turbo, from: "@hotwired/turbo"

import hotkeys from "hotkeys-js"
hotkeys "cmd+k,ctrl+k" do |event|
  event.prevent_default()
  document.query_selector("bridgetown-search-form > input").focus()
end

import "turbo_transitions"

async def import_additional_dependencies()
  await import("bridgetown-quick-search/dist")

  document.query_selector("bridgetown-search-form > input").add_event_listener :keydown do |event|
    if event.key_code == 13
      document.query_selector("bridgetown-search-results").show_results_for_query(event.target.value)
    end

    event.target.closest("sl-bar-item").query_selector("kbd").style.display = "none"
  end

  await import("wiggle_note")
end

import_additional_dependencies()

import "index.css"

import components from "bridgetownComponents/**/*.{js,jsx,js.rb,css}"
Object.entries(components)

register_icon_library('remixicon', 
  resolver: -> name do
    match = name.match(/^(.*?)\/(.*?)(-(fill))?$/)
    match[1] = match[1].char_at(0).upcase() + match[1].slice(1)
    "https://cdn.jsdelivr.net/npm/remixicon@2.5.0/icons/#{match[1]}/#{match[2]}#{match[3] || '-line'}.svg";
  end,
  mutator: -> svg { svg.set_attribute('fill', 'currentColor') }
)

# This is weird, I'm not sure why I have to do this.
document.add_event_listener "turbo:load" do
  document.query_selector_all("sl-button").each do |button|
    if button.parent_node.local_name == :a
      button.add_event_listener :click do |event|
        event.prevent_default()
        Turbo.visit event.current_target.parent_node.href
      end
    end
  end
end
