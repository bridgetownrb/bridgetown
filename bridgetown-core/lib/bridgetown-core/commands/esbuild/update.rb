# frozen_string_literal: true

template "esbuild.defaults.js.erb", "config/esbuild.defaults.js", force: true
copy_file "jsconfig.json"
say "🎉 esbuild configuration updated successfully!"
say "You may need to add `$styles/` to the front of your main CSS imports."
say "See https://www.bridgetownrb.com/docs/frontend-assets#esbuild-setup for details."
