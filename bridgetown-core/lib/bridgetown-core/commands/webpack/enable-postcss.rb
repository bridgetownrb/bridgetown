# frozen_string_literal: true

default_postcss_config = File.expand_path("../../../site_template/postcss.config.js.erb", __dir__)

template default_postcss_config, "postcss.config.js"
template "webpack.defaults.js.erb", "config/webpack.defaults.js", force: true

unless Bridgetown.environment.test?
  packages = %w(postcss postcss-loader postcss-flexbugs-fixes postcss-preset-env)
  run "yarn add -D #{packages.join(" ")}"
  run "yarn remove sass sass-loader"
end
