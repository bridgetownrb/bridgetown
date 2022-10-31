# frozen_string_literal: true

unless Bridgetown::Utils.frontend_bundler_type == :esbuild
  error_message = "#{"esbuild.config.js".bold} not found. (This configuration doesn't currently " \
                  "support Webpack.)"

  @logger.error "\nError:".red, "🚨 #{error_message}"

  return
end

say_status :lit, "Installing Lit + SSR Plugin..."

add_gem "bridgetown-lit-renderer"

run "yarn add lit esbuild-plugin-lit-css bridgetown-lit-renderer"

copy_file in_templates_dir("lit-ssr.config.js"), "config/lit-ssr.config.js"
copy_file in_templates_dir("lit-components-entry.js"), "config/lit-components-entry.js"
copy_file in_templates_dir("esbuild-plugins.js"), "config/esbuild-plugins.js"

insert_into_file "esbuild.config.js",
                 after: 'const build = require("./config/esbuild.defaults.js")' do
  <<~JS

    const { plugins } = require("./config/esbuild-plugins.js")
  JS
end

found_match = false
gsub_file "esbuild.config.js", %r{const esbuildOptions = {}\n} do |_match|
  found_match = true

  <<~JS
    const esbuildOptions = {
      plugins: [...plugins],
      // Uncomment the following to opt into `.global.css` & `.lit.css` nomenclature.
      // Read https://www.bridgetownrb.com/docs/components/lit#sidecar-css-files for documentation.
      /*
      postCssPluginConfig: {
        filter: /(?:index|\.global)\.css$/,
      },
      */
    }
  JS
end

unless found_match
  insert_into_file "esbuild.config.js",
                   after: 'const { plugins } = require("./config/esbuild-plugins.js")' do
    <<~JS

      // TODO: You will manually need to move any plugins below you wish to share with
      // Lit SSR into the `config/esbuild-plugins.js` file.
      // Then add `...plugins` as an item in your plugins array.
      //
      // You might also want to include the following in your esbuild config to opt into
      // `.global.css` & `.lit.css` nomenclature.
      // Read https://www.bridgetownrb.com/docs/components/lit#sidecar-css-files for documentation.
      /*
      postCssPluginConfig: {
        filter: /(?:index|\.global)\.css$/,
      },
      */
    JS
  end
end

copy_file in_templates_dir("happy-days.lit.js"), "src/_components/happy-days.lit.js"

javascript_import do
  <<~JS
    import "bridgetown-lit-renderer"
  JS
end

insert_into_file "frontend/javascript/index.js",
                 before: 'import components from "bridgetownComponents/**/*.{js,jsx,js.rb,css}"' do
  <<~JS
    // To opt into `.global.css` & `.lit.css` nomenclature, change the `css` extension below to `global.css`.
    // Read https://www.bridgetownrb.com/docs/components/lit#sidecar-css-files for documentation.
  JS
end

add_initializer :"bridgetown-lit-renderer"

if found_match
  say_status :lit, "Lit is now configured!"
  say_status :lit,
             "The `config/esbuild-plugins.js` file will let you add full-stack plugins in future."
else
  say_status :lit, "Lit is just about configured!"
  say_status :lit, "You will need to edit `esbuild.config.js` to finish setting up the plugin."
end

say "Check out the example `happy-days.lit.js` file in `src/_components`", :blue
say 'For further reading, check out "https://www.bridgetownrb.com/docs/components/lit"', :blue
