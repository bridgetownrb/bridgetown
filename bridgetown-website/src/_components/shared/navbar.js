function menuShow(toggler) {
  let bar = document.querySelector("body > nav sl-bar")
  bar.setAttribute("expanded", true)
  for (let item of bar.querySelectorAll("sl-bar-item[expandable]")) {
    item.classList.add("fade-in-always")
  }
  toggler.querySelector("sl-icon").name = "system/close"
}

function menuHide(toggler) {
  let bar = document.querySelector("body > nav sl-bar")
  bar.setAttribute("expanded", false)
  for (let item of bar.querySelectorAll("sl-bar-item[expandable]")) {
    item.classList.remove("fade-in-always")
  }
  toggler.querySelector("sl-icon").name = "system/menu"
}

function setCurrentNavItem(nav, path) {
  let link = nav.querySelector(`a[href="${path}"]`)
  let linkPathname = new URL(link.href).pathname

  return linkPathname === location.pathname
    ? link.setAttribute("aria-current", "page")
    : link.setAttribute("aria-current", "true")
}

document.addEventListener("turbo:load", () => {
  let search = document.querySelector("bridgetown-search-results")
  search.showResults = false
  search.results = []

  let nav = document.querySelector("body > nav")

  menuHide(nav.querySelector("sl-button[menutoggle]"))

  for (let item of nav.querySelectorAll("a")) {
    item.removeAttribute("aria-current")
  }

  if (location.pathname === "/") {
    setCurrentNavItem(nav, "/")
  } else if (location.pathname.startsWith("/docs")) {
    setCurrentNavItem(nav, "/docs")
  } else if (location.pathname.startsWith("/plugins")) {
    setCurrentNavItem(nav, "/plugins")
  } else if (location.pathname.startsWith("/community")) {
    setCurrentNavItem(nav, "/community")
  } else if (location.pathname.startsWith("/blog") || document.body.classList.contains("post")) {
    setCurrentNavItem(nav, "/blog")
  }
})

window.menuHide = menuHide
window.menuShow = menuShow
