# frozen_string_literal: true

say_status "is-land", "Installing <is-land>..."

run "yarn add @11ty/is-land"

javascript_import do
  <<~JS
    import "@11ty/is-land/is-land.js"
    import "@11ty/is-land/is-land-autoinit.js"
  JS
end

say_status "is-land", "<is-land> is now configured!"
say 'For further reading, check out "https://www.bridgetownrb.com/docs/islands"', :blue
