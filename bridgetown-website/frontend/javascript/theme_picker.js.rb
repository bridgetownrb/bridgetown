class ThemePicker < HTMLElement
  THEME_STORAGE_KEY = "theme"

  LIGHT = "light"
  DARK = "dark"
  DEFAULT = "default"

  def options_icons
    @_options_icons ||= {
      LIGHT   => "sun",
      DARK    => "moon",
      DEFAULT => media_prefers_color_scheme_dark ? "moon" : "sun",
    }
  end

  def media_prefers_color_scheme_dark
    window.matchMedia("(prefers-color-scheme: #{DARK})").matches
  end

  def build_template(option_name)
    <<~COMPONENT
      <style>
        :host {
          position: absolute;
          right: 10px;
          top: 10px;
          z-index: 30;
        }
        wa-button::part(base) {
          width: auto; /* fix that's fixed in next Web Awesome release */
        }
      </style>
      <wa-dropdown>
        <wa-button variant="brand" appearance="outlined" size="small" slot="trigger" with-caret>
          <wa-icon id="dropdown-button-icon" name="#{options_icons[option_name]}" label="Choose color theme"></wa-icon>
        </wa-button>

        #{
          Object.entries(options_icons).map do |entry|
            option, icon = entry

            <<~MENU_ITEM
              #{option == DEFAULT ? "<wa-divider></wa-divider>" : ""}
              <wa-dropdown-item #{"checked" if option_name == option} value="#{option}">
                #{option}
                <wa-icon slot="icon" name="#{icon}"></wa-icon>
              </wa-dropdown-item>
            MENU_ITEM
          end.join("")
        }
      </wa-dropdown>
    COMPONENT
  end

  def initialize
    super()

    option_name = local_storage.get_item(THEME_STORAGE_KEY)

    option_name ||= begin # fixes Ruby2JS issue # rubocop:disable Style/RedundantBegin
      if media_prefers_color_scheme_dark
        DEFAULT
      else
        LIGHT
      end
    end

    set_theme_classes(option_name)

    @shadow_root = self.attach_shadow({ mode: "open" })

    @shadow_root.innerHTML = build_template(option_name)
    @dropdown_button_icon = @shadow_root.query_selector("#dropdown-button-icon")

    on_theme_toggle(option_name)

    dropdown = @shadow_root.query_selector("wa-dropdown")

    dropdown.add_event_listener("wa-select") do |event|
      option_name = event.detail.item.value

      local_storage.set_item(THEME_STORAGE_KEY, option_name)

      on_theme_toggle(option_name)
    end
  end

  def on_theme_toggle(option_name)
    @shadow_root.query_selector_all("wa-menu-item").each do |menu_item|
      value = menu_item.get_attribute("value")

      if value == option_name
        menu_item.set_attribute("checked", true)
      else
        menu_item.remove_attribute("checked")
      end
    end

    set_theme_classes(option_name)

    @dropdown_button_icon.set_attribute("name", options_icons[option_name])
  end

  def set_theme_classes(option_name)
    if option_name == DARK || (option_name == DEFAULT && media_prefers_color_scheme_dark)
      document.document_element.class_list.add("theme-dark", "wa-theme-dark")
      search_results = document.query_selector("bridgetown-search-results")
      search_results.set_attribute("theme", "dark") if search_results
    else
      document.document_element.class_list.remove("theme-dark", "wa-theme-dark")
      search_results = document.query_selector("bridgetown-search-results")
      search_results.set_attribute("theme", "light") if search_results
    end
  end
end

custom_elements.define "theme-picker", ThemePicker
