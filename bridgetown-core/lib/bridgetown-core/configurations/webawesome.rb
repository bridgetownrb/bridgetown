# frozen_string_literal: true

say_status :webawesome, "Installing Web Awesome..."

add_npm_package "@awesome.me/webawesome"

stylesheet_import = <<~CSS
  /* Import the base Web Awesome stylesheet: */
  @import "@awesome.me/webawesome/dist/styles/webawesome.css";

CSS

if File.exist?("frontend/styles/index.css")
  say 'Adding Web Awesome stylesheet import to "frontend/styles/index.css"...', :magenta
  prepend_to_file "frontend/styles/index.css", stylesheet_import
elsif File.exist?("frontend/styles/index.scss")
  say 'Adding Web Awesome stylesheet import to "frontend/styles/index.scss"...', :magenta
  prepend_to_file "frontend/styles/index.scss", stylesheet_import
else
  say "\nPlease add the following lines to your CSS index file:"
  say stylesheet_import
end

say 'Adding Web Awesome component imports to "frontend/javascript/index.js"...', :magenta

javascript_import do
  <<~JS

    // Example Web Awesome components. Mix 'n' match however you like!
    import "@awesome.me/webawesome/dist/components/button/button.js"
    import "@awesome.me/webawesome/dist/components/icon/icon.js"
    import "@awesome.me/webawesome/dist/components/spinner/spinner.js"
  JS
end

say_status :webawesome, "Web Awesome is now configured!"

say 'For further reading, check out "https://webawesome.com"', :blue
