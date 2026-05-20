class ThemePicker extends HTMLElement {
  static get mediaPrefersColorSchemeDark() {
    return window.ThemeManager.mediaPrefersColorSchemeDark
  }

  static setThemeClasses(optionName) {
    let searchResults

    window.ThemeManager.setThemeClasses(optionName)

    if (
      optionName === this.DARK ||
      (optionName === this.DEFAULT && this.mediaPrefersColorSchemeDark)
    ) {
      searchResults = document.querySelector("bridgetown-search-results")
      if (searchResults) searchResults.setAttribute("theme", "dark")
    } else {
      searchResults = document.querySelector("bridgetown-search-results")
      if (searchResults) searchResults.setAttribute("theme", "light")
    }
  }

  static {
    this.THEME_STORAGE_KEY = window.ThemeManager.THEME_STORAGE_KEY
    this.LIGHT = window.ThemeManager.LIGHT
    this.DARK = window.ThemeManager.DARK
    this.DEFAULT = window.ThemeManager.DEFAULT

    let optionName = localStorage.getItem(this.THEME_STORAGE_KEY)

    optionName = optionName ||
      (this.mediaPrefersColorSchemeDark ? this.DEFAULT : this.LIGHT)

    this.setThemeClasses(optionName)

    const systemDark = window.matchMedia("(prefers-color-scheme: dark)")
    const applyDark = () => {
      const themeKey = localStorage.getItem(this.THEME_STORAGE_KEY)
      if (!themeKey || themeKey === this.DEFAULT) {
        console.log("OK!")
        this.setThemeClasses(this.DEFAULT)
      }
    }
    systemDark.addEventListener("change", applyDark)

    customElements.define("theme-picker", this)
  }

  get optionsIcons() {
    return (this._OptionsIcons = this._OptionsIcons || {
      [this.constructor.LIGHT]: "sun",
      [this.constructor.DARK]: "moon",
      [this.constructor.DEFAULT]: this.constructor.mediaPrefersColorSchemeDark ? "moon" : "sun",
    })
  }

  buildTemplate(optionName) {
    return `<style>
    sl-button::part(base) {
      color: var(--color-lighter-green);
      border-color: var(--color-light-green);
    }
    </style><sl-dropdown>
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

    this.attachShadow({ mode: "open" })

    this.style.position = "absolute"
    this.style.right = "10px"
    this.style.top = "10px"
    this.style["z-index"] = "30"

    // TODO: DRY this up, see static section above
    let optionName = localStorage.getItem(this.constructor.THEME_STORAGE_KEY)
    optionName = optionName ||
      (this.constructor.mediaPrefersColorSchemeDark ? this.constructor.DEFAULT : this.constructor.LIGHT)

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

    this.constructor.setThemeClasses(optionName)
    this._dropdownButtonIcon.setAttribute("name", this.optionsIcons[optionName])
  }
}
