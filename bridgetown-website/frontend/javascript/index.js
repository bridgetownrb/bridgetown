import "../styles/index.scss"
import Swup from "swup"
import SwupSlideTheme from "@swup/slide-theme"
import SwupBodyClassPlugin from "@swup/body-class-plugin"
import SwupScrollPlugin from "@swup/scroll-plugin"
import animateScrollTo from "animated-scroll-to"
import "bridgetown-quick-search"
import { toggleMenuIcon, addHeadingAnchors } from "./lib/functions.js.rb"

document.addEventListener('DOMContentLoaded', () => {
  // Docs layout has a sidebar, so we need to adjust Swup accordingly
  let containers, mainEl

  if (document.querySelector("layout-sidebar")) {
    mainEl = "#swup-with-sidebar"
    containers = [mainEl, "layout-sidebar", "#topnav"]
    let navActivated = false
    document.querySelector("#mobile-nav-activator").addEventListener("click", event => {
      animateScrollTo(
        document.querySelector("layout-sidebar"),
        {
          maxDuration: 500
        }
      )
      if (!navActivated) {
        const button = event.currentTarget
        toggleMenuIcon(button)
        navActivated = true;
        setTimeout(() => { toggleMenuIcon(button); navActivated = false }, 6000)
      }
    })
  } else {
    mainEl = "#swup"
    containers = [mainEl, "#topnav"]
  }

  if(!window.matchMedia('(prefers-reduced-motion)').matches) {
    const swup = new Swup({
      containers: containers,
      plugins: [
        new SwupSlideTheme({mainElement: mainEl}),
        new SwupBodyClassPlugin(),
        new SwupScrollPlugin({animateScroll: false})
      ],

    })

    swup.on('contentReplaced', function() {
      addHeadingAnchors()
    })
  }

  addHeadingAnchors()
})
