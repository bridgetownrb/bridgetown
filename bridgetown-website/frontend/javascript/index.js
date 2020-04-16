import "../styles/index.scss"
import Swup from "swup"
import SwupSlideTheme from "@swup/slide-theme"
import SwupBodyClassPlugin from "@swup/body-class-plugin"
import SwupScrollPlugin from "@swup/scroll-plugin"

let containers, mainEl

if (document.querySelector("#sidebar")) {
  mainEl = "#swup-with-sidebar"
  containers = [mainEl, "#sidebar", "#topnav"]
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

//console.info("Bridgetown is loaded!")
