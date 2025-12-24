import "@shoelace-style/shoelace/dist/themes/light.css"
import "@shoelace-style/shoelace/dist/themes/dark.css"
import "@shoelace-style/shoelace/dist/components/alert/alert.js"
import "@shoelace-style/shoelace/dist/components/avatar/avatar.js"
import "@shoelace-style/shoelace/dist/components/breadcrumb/breadcrumb.js"
import "@shoelace-style/shoelace/dist/components/breadcrumb-item/breadcrumb-item.js"
import "@shoelace-style/shoelace/dist/components/button/button.js"
import "@shoelace-style/shoelace/dist/components/card/card.js"
import "@shoelace-style/shoelace/dist/components/dialog/dialog.js"
import "@shoelace-style/shoelace/dist/components/divider/divider.js"
import "@shoelace-style/shoelace/dist/components/dropdown/dropdown.js"
import "@shoelace-style/shoelace/dist/components/icon/icon.js"
import "@shoelace-style/shoelace/dist/components/input/input.js"
import "@shoelace-style/shoelace/dist/components/menu/menu.js"
import "@shoelace-style/shoelace/dist/components/menu-item/menu-item.js"
import "@shoelace-style/shoelace/dist/components/tab-group/tab-group.js"
import "@shoelace-style/shoelace/dist/components/tab-panel/tab-panel.js"
import "@shoelace-style/shoelace/dist/components/tab/tab.js"
import "@shoelace-style/shoelace/dist/components/tag/tag.js"
import { registerIconLibrary } from "@shoelace-style/shoelace/dist/utilities/icon-library.js"
import { setBasePath } from "@shoelace-style/shoelace/dist/utilities/base-path.js"

import * as Turbo from "@hotwired/turbo"

import hotkeys from "hotkeys-js"

hotkeys("cmd+k,ctrl+k", (event) => {
  event.preventDefault()
  document.querySelector("bridgetown-search-form > input").focus()
})

import "./turbo_transitions.js"

async function importAdditionalDependencies() {
  await import("bridgetown-quick-search")

  document.querySelector("bridgetown-search-form > input").addEventListener("keydown", (event) => {
    if (event.keyCode === 13) {
      document.querySelector("bridgetown-search-results").showResultsForQuery(event.target.value)
    }
    event.target.closest("sl-bar-item").querySelector("kbd").style.display = "none"
  })

  await import("./wiggle_note.js")
  await import("./theme_picker.js")
}

importAdditionalDependencies()

import "$styles/index.css"

import components from "bridgetownComponents/**/*.{js,jsx,js.rb,css}"
Object.entries(components)

registerIconLibrary("remixicon", {
  resolver(name) {
    let match = name.match(/^(.*?)\/(.*?)(-(fill))?$/m)
    match[1] = match[1].charAt(0).toUpperCase() + match[1].slice(1)
    return `https://cdn.jsdelivr.net/npm/remixicon@3.3.0/icons/${match[1]}/${match[2]}${
      match[3] || "-line"
    }.svg`
  },
  mutator(svg) {
    return svg.setAttribute("fill", "currentColor")
  },
})
setBasePath("/images")

// This is weird, I'm not sure why I have to do this.
document.addEventListener("turbo:load", () => {
  for (let button of document.querySelectorAll("sl-button")) {
    if (button.parentNode.localName === "a") {
      button.addEventListener("click", (event) => {
        event.preventDefault()
        Turbo.visit(event.currentTarget.parentNode.href)
      })
    }
  }
})
