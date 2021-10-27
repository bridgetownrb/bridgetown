# frozen_string_literal: true

say "Installing Turbo...", :green

run("yarn add @hotwired/turbo")

say 'Adding Turbo to "frontend/javascript/index.js"...', :magenta

javascript_import do
  <<~JS
    import Turbo from "@hotwired/turbo"
  JS
end

say "Turbo successfully added", :green
say 'For further reading, check out "https://turbo.hotwired.dev/"', :blue
