import "../styles/index.scss"
import Swup from "swup"
import SwupSlideTheme from "@swup/slide-theme"
import SwupBodyClassPlugin from "@swup/body-class-plugin"
import SwupScrollPlugin from "@swup/scroll-plugin"
import animateScrollTo from "animated-scroll-to"

const toggleMenuIcon = button => {
  button.querySelectorAll(".icon").forEach(item => {
    item.classList.toggle("not-shown")
  })
  button.querySelector(".icon:not(.not-shown)").classList.add("shown")
}

document.addEventListener('DOMContentLoaded', () => {
  // Docs layout has a sidebar, so we need to adjust Swup accordingly
  let containers, mainEl

  if (document.querySelector("#sidebar")) {
    mainEl = "#swup-with-sidebar"
    containers = [mainEl, "#sidebar", "#topnav"]
    let navActivated = false
    document.querySelector("#mobile-nav-activator").addEventListener("click", event => {
      animateScrollTo(
        document.querySelector("#sidebar"),
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

  const swup = new Swup({
    containers: containers,
    plugins: [
      new SwupSlideTheme({mainElement: mainEl}),
      new SwupBodyClassPlugin(),
      new SwupScrollPlugin({animateScroll: false})
    ]
  })

/*  console.info(swup)
  swup.preloadPage('/')
  swup.preloadPage('/docs/')
  swup.preloadPage('/about/')
  swup.preloadPage('/blog/') */
})
