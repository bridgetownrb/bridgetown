# frozen_string_literal: true

template "esbuild.defaults.js.erb", "config/esbuild.defaults.js", force: true
copy_file "jsconfig.json"

unless File.read("package.json").include?('"type": "module"')
  insert_into_file "package.json",
                   after: '"private": true,' do
    <<-JS.chomp

  "type": "module",
    JS
  end
end

gsub_file "postcss.config.js", "module.exports =", "export default"
gsub_file "esbuild.config.js", 'const build = require("./config/esbuild.defaults.js")',
          'import build from "./config/esbuild.defaults.js"'
add_npm_package "esbuild@latest glob@latest"

say "\n🎉 esbuild configuration updated successfully!"
say "You may need to add `$styles/` to the front of your main CSS imports."
say "See https://www.bridgetownrb.com/docs/frontend-assets#esbuild-setup for details."
