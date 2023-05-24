# frozen_string_literal: true

say_status :turbo, "Installing Turbo..."

run("yarn add @hotwired/turbo")
run("yarn add turbo-shadow")

say_status :turbo, 'Adding Turbo to "frontend/javascript/index.js"...', :magenta

javascript_import do
  <<~JS
    import * as Turbo from "@hotwired/turbo"

    /**
     * Adds support for declarative shadow DOM. Requires your HTML <head> to include:
     * `<meta name="turbo-cache-control" content="no-cache" />`
     */
    import * as TurboShadow from "turbo-shadow"

    /**
     * Uncomment the line below to add transition animations when Turbo navigates.
     * Use data-turbo-transition="false" on your <main> element for pages where
     * you don't want any transition animation.
     */
    // import "./turbo_transitions.js"
  JS
end

copy_file in_templates_dir("turbo_transitions.js"), "frontend/javascript/turbo_transitions.js"

say_status :turbo, "Turbo successfully added!", :magenta
say_status :turbo, "For declarative shadow DOM support, you will need to update", :blue
say_status :turbo, "your HTML <head> to add the following code:", :blue
say %(<meta name="turbo-cache-control" content="no-cache" />)
say_status :turbo, "Check out your index.js file for optional animation setup.", :blue
say_status :turbo, 'For further reading, visit "https://turbo.hotwired.dev/"', :blue
