# frozen_string_literal: true

say_status "is-land", "Installing <is-land>..."

add_npm_package "@11ty/is-land"

javascript_import do
  <<~JS
    import "@11ty/is-land/is-land.js"
  JS
end

say_status "is-land", "<is-land> is now configured!"
say 'For further reading, check out "https://www.bridgetownrb.com/docs/islands"', :blue
