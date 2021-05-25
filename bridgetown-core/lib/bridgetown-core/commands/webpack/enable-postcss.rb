# frozen_string_literal: true

create_file "postcss.config.js"
template "webpack.defaults.js.erb", "webpack.defaults.js", force: true

packages = %w(postcss@8.3.0 postcss-loader@4.3.0 postcss-flexbugs-fixes postcss-preset-env)
run "yarn add -D #{packages.join(' ')}"
run "yarn remove sass sass-loader"