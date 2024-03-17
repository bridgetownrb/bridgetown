# frozen_string_literal: true

require "fileutils"

say "Installing Stimulus...", :green

run("yarn add @hotwired/stimulus")

say 'Adding Stimulus to "frontend/javascript/index.js"...', :magenta

javascript_import do
  <<~JS
    import { Application } from "@hotwired/stimulus"
  JS
end

javascript_dir = File.join("frontend", "javascript")

append_to_file(File.join(javascript_dir, "index.js")) do
  <<~JS

    window.Stimulus = Application.start()

    import controllers from "./controllers/**/*.{js,js.rb}"
    Object.entries(controllers).forEach(([filename, controller]) => {
      if (filename.includes("_controller.") || filename.includes("-controller.")) {
        const identifier = filename.replace("./controllers/", "")
          .replace(/[_-]controller\\..*$/, "")
          .replace(/_/g, "-")
          .replace(/\\//g, "--")

        Stimulus.register(identifier, controller.default)
      }
    })
  JS
end

controller_dir = File.join(javascript_dir, "controllers")

say "Creating a `./#{controller_dir}` directory...", :magenta
FileUtils.mkdir_p(controller_dir)

say "Creating an example Stimulus Controller for you!...", :magenta
create_file(File.join(controller_dir, "example_controller.js")) do
  <<~JS
    import { Controller } from "@hotwired/stimulus"
    export default class extends Controller {
      connect() {
        console.log("Hello, Stimulus!", this.element)
      }
    }
  JS
end

say "Stimulus successfully added", :green

say "To start adding controllers, visit the `./frontend/javascript/controllers/` directory", :blue
say "Make sure your controllers follow the `[name]_controller.js` convention", :blue
say 'For further reading, check out "https://stimulus.hotwired.dev/"', :blue
