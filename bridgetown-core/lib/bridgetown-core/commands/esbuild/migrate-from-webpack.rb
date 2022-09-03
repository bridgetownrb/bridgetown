# frozen_string_literal: true

# rubocop:disable Layout/LineLength

remove_file "webpack.config.js"
remove_file "config/webpack.defaults.js"

apply find_in_source_paths("setup.rb"), verbose: false

default_postcss_config = File.expand_path("../../../site_template/postcss.config.js.erb", __dir__)
template default_postcss_config, "postcss.config.js"

unless Bridgetown.environment.test?
  required_packages = %w(esbuild glob postcss postcss-flexbugs-fixes postcss-preset-env postcss-import postcss-load-config@4.0.1)
  redundant_packages = %w(esbuild-loader webpack webpack-cli webpack-manifest-plugin webpack-merge css-loader file-loader mini-css-extract-plugin postcss-loader)

  say "Installing required packages"

  gsub_file "package.json", %r!    "postcss-focus-within": "^4.0.0",?!, ""

  run "yarn add -D #{required_packages.join(" ")}"

  packages_to_remove = package_json["devDependencies"].slice(*redundant_packages).keys
  unless packages_to_remove.empty?
    confirm = ask "\nThe following packages will be removed: \n\n#{packages_to_remove.join("\n")}\n\nWould you like to continue? [Yn]"
    return unless confirm.casecmp?("Y")

    run "yarn remove #{packages_to_remove.join(" ")}"
  end
end

gsub_file "Rakefile", %(desc "Build the frontend with Webpack for deployment"), %(desc "Build the frontend with esbuild for deployment")
gsub_file "Rakefile", %(desc "Watch the frontend with Webpack during development"), %(desc "Watch the frontend with esbuild during development")
gsub_file "Rakefile", %(sh "yarn run webpack-build"), %(sh "yarn run esbuild")
gsub_file "Rakefile", %(sh "yarn run webpack-dev --color"), %(sh "yarn run esbuild-dev")
gsub_file "package.json", %("webpack-build": "webpack --mode production"), %("esbuild": "node esbuild.config.js --minify")
gsub_file "package.json", %("webpack-dev": "webpack --mode development -w"), %("esbuild-dev": "node esbuild.config.js --watch")

say "🎉 Migration steps to esbuild finished!"
say "Make sure you replace your `webpack_path` helpers with `asset_path` helpers in your templates"

# rubocop:enable Layout/LineLength
