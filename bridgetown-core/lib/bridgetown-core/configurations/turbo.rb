# frozen_string_literal: true

say_status :turbo, "Installing Turbo..."

run("yarn add @hotwired/turbo")

say_status :turbo, 'Adding Turbo to "frontend/javascript/index.js"...', :magenta

javascript_import do
  <<~JS
    import * as Turbo from "@hotwired/turbo"

    // Uncomment the line below to add transition animations when Turbo navigates.
    // We recommend adding <meta name="turbo-cache-control" content="no-preview" />
    // to your HTML head if you turn on transitions. Use data-turbo-transition="false"
    // on your <main> element for pages where you don't want any transition animation.
    //
    // import "./turbo_transitions.js"
  JS
end

copy_file in_templates_dir("turbo_transitions.js"), "frontend/javascript/turbo_transitions.js"

say_status :turbo, "Turbo successfully added!", :magenta
say_status :turbo, "Take a look in your index.js file for optional animation setup.", :blue
say_status :turbo, 'For further reading, check out "https://turbo.hotwired.dev/"', :blue
