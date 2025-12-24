class ThemePicker extends HTMLElement {
  static {
    this.THEME_STORAGE_KEY = "theme"
    this.LIGHT = "light"
    this.DARK = "dark"
    this.DEFAULT = "default"

    customElements.define("theme-picker", this)
  }

  get optionsIcons() {
    return (this._OptionsIcons = this._OptionsIcons || {
      [this.constructor.LIGHT]: "sun",
      [this.constructor.DARK]: "moon",
      [this.constructor.DEFAULT]: this.mediaPrefersColorSchemeDark ? "moon" : "sun",
    })
  }

  get mediaPrefersColorSchemeDark() {
    return window.matchMedia(`(prefers-color-scheme: ${this.constructor.DARK})`).matches
  }

  buildTemplate(optionName) {
    return `<sl-dropdown>
  <sl-button slot="trigger" caret size="small" outline>
    <sl-icon id="dropdown-button-icon" name="${
      this.optionsIcons[optionName]
    }" label="Choose color theme"></sl-icon>
  </sl-button>

  <sl-menu>
    ${Object.entries(this.optionsIcons)
      .map((entry) => {
        let [option, icon] = entry
        return `${option === this.constructor.DEFAULT ? "<sl-divider></sl-divider>" : ""}
<sl-menu-item ${optionName === option ? "checked" : null} value="${option}">
  ${option}
  <sl-icon slot="prefix" name="${icon}"></sl-icon>
</sl-menu-item>
`
      })
      .join("")}
  </sl-menu>
</sl-dropdown>
`
  }
  constructor() {
    super()

    let optionName = localStorage.getItem(this.constructor.THEME_STORAGE_KEY)

    optionName =
      optionName ||
      (this.mediaPrefersColorSchemeDark ? this.constructor.DEFAULT : this.constructor.LIGHT)

    this.setThemeClasses(optionName)
    this.attachShadow({ mode: "open" })

    this.style.position = "absolute"
    this.style.right = "10px"
    this.style.top = "10px"
    this.style["z-index"] = "30"

    this.shadowRoot.innerHTML = this.buildTemplate(optionName)
    this._dropdownButtonIcon = this.shadowRoot.querySelector("#dropdown-button-icon")

    this.onThemeToggle(optionName)

    let dropdown = this.shadowRoot.querySelector("sl-dropdown")
    dropdown.addEventListener("sl-select", (event) => {
      optionName = event.detail.item.value
      localStorage.setItem(this.constructor.THEME_STORAGE_KEY, optionName)
      return this.onThemeToggle(optionName)
    })
  }

  onThemeToggle(optionName) {
    for (let menuItem of this.shadowRoot.querySelectorAll("sl-menu-item")) {
      let value = menuItem.getAttribute("value")
      if (value === optionName) {
        menuItem.setAttribute("checked", true)
      } else {
        menuItem.removeAttribute("checked")
      }
    }

    this.setThemeClasses(optionName)
    this._dropdownButtonIcon.setAttribute("name", this.optionsIcons[optionName])
  }

  setThemeClasses(optionName) {
    let searchResults

    if (
      optionName === this.constructor.DARK ||
      (optionName === this.constructor.DEFAULT && this.mediaPrefersColorSchemeDark)
    ) {
      document.documentElement.classList.add("theme-dark", "sl-theme-dark")
      searchResults = document.querySelector("bridgetown-search-results")
      if (searchResults) searchResults.setAttribute("theme", "dark")
    } else {
      document.documentElement.classList.remove("theme-dark", "sl-theme-dark")
      searchResults = document.querySelector("bridgetown-search-results")
      if (searchResults) searchResults.setAttribute("theme", "light")
    }
  }
}
