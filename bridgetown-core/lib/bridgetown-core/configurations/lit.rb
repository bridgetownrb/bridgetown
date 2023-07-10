# frozen_string_literal: true

unless Bridgetown::Utils.frontend_bundler_type == :esbuild
  error_message = "#{"esbuild.config.js".bold} not found. (This configuration doesn't currently " \
                  "support Webpack.)"

  @logger.error "\nError:".red, "🚨 #{error_message}"

  return
end

say_status :lit, "Installing Lit + SSR Plugin..."

add_gem "bridgetown-lit-renderer", version: "2.1.0.beta2"

run "yarn add lit esbuild-plugin-lit-css bridgetown-lit-renderer@2.1.0-beta2"

copy_file in_templates_dir("lit-ssr.config.js"), "config/lit-ssr.config.js"
copy_file in_templates_dir("lit-components-entry.js"), "config/lit-components-entry.js"
copy_file in_templates_dir("esbuild-plugins.js"), "config/esbuild-plugins.js"

insert_into_file "esbuild.config.js",
                 after: 'const build = require("./config/esbuild.defaults.js")' do
  <<~JS

    const { plugins } = require("./config/esbuild-plugins.js")
  JS
end

insert_into_file "esbuild.config.js",
                 after: "\n  plugins: [\n" do
  <<-JS
    ...plugins,
  JS
end

copy_file in_templates_dir("happy-days.lit.js"), "src/_components/happy-days.lit.js"

javascript_import do
  <<~JS
    import "bridgetown-lit-renderer"
  JS
end

add_initializer :"bridgetown-lit-renderer"

say_status :lit, "Lit is now configured!"
say_status :lit,
           "The `config/esbuild-plugins.js` file will let you add full-stack plugins in future."

say "Check out the example `happy-days.lit.js` file in `src/_components`", :blue
say 'For further reading, check out "https://www.bridgetownrb.com/docs/components/lit"', :blue
