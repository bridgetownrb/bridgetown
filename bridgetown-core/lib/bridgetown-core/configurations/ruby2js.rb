# frozen_string_literal: true

unless Bridgetown::Utils.frontend_bundler_type == :esbuild
  error_message = "#{"esbuild.config.js".bold} not found. (This configuration doesn't currently support Webpack.)"

  @logger.error "\nError:".red, "🚨 #{error_message}"

  return
end

say_status :ruby2js, "Installing Ruby2JS..."

run "yarn add -D @ruby2js/esbuild-plugin"

found_match = false
gsub_file "esbuild.config.js", %r{const esbuildOptions = {}\n} do |_match|
  found_match = true

  <<~JS
    const ruby2js = require("@ruby2js/esbuild-plugin")

    const esbuildOptions = {
      plugins: [
        // See docs on Ruby2JS options here: https://www.ruby2js.com/docs/options
        ruby2js({
          eslevel: 2022,
          autoexports: "default",
          filters: ["camelCase", "functions", "lit", "esm", "return"]
        })
      ]
    }
  JS
end

unless found_match
  insert_into_file "esbuild.config.js",
                   after: 'const build = require("./config/esbuild.defaults.js")' do
    <<~JS

      const ruby2js = require("@ruby2js/esbuild-plugin")

      // Uncomment and move the following into your plugins array:
      //
      //  ruby2js({
      //    eslevel: 2022,
      //    autoexports: "default",
      //    filters: ["camelCase", "functions", "lit", "esm", "return"]
      //  })
      //
      // See docs on Ruby2JS options here: https://www.ruby2js.com/docs/options

    JS
  end
end

copy_file in_templates_dir("hello_world.js.rb"), "src/_components/hello_world.js.rb"

say_status :ruby2js, "Ruby2JS is now configured!"

say "Check out the example `hello_world.js.rb` file in `src/_components`", :blue
say 'For further reading, check out "https://www.ruby2js.com"', :blue
