# frozen_string_literal: true

unless Bridgetown::Utils.frontend_bundler_type == :esbuild
  error_message = "#{"esbuild.config.js".bold} not found. (This configuration doesn't currently " \
                  "support Webpack.)"

  @logger.error "\nError:".red, "🚨 #{error_message}"

  return
end

say_status :ruby2js, "Installing Ruby2JS..."

add_gem "ruby2js"
run "yarn add -D @ruby2js/esbuild-plugin"

insert_into_file "esbuild.config.js",
                 after: 'const build = require("./config/esbuild.defaults.js")' do
  <<~JS

    const ruby2js = require("@ruby2js/esbuild-plugin")
  JS
end

insert_into_file "esbuild.config.js",
                 after: "\n  plugins: [\n" do
  <<-JS
    ruby2js(),
  JS
end

copy_file in_templates_dir("ruby2js.rb"), "config/ruby2js.rb"
copy_file in_templates_dir("hello_world.js.rb"), "src/_components/hello_world.js.rb"

say_status :ruby2js, "Ruby2JS is now configured!"

say "Check out the example `hello_world.js.rb` file in `src/_components`", :blue
say "Ruby2JS configuration options are saved in `config/ruby2js.rb`", :blue
say 'For further reading, check out "https://www.ruby2js.com"', :blue
