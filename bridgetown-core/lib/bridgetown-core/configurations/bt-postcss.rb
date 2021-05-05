# frozen_string_literal: true

# rubocop:disable all

TEMPLATE_PATH = File.expand_path("./bt-postcss", __dir__)

begin
  find_in_source_paths("postcss.config.js")
rescue Thor::Error
  error_message = "#{"postcss.config.js".bold} not found. Please configure postcss in your project."

  @logger.error "\nError:".red, "🚨 #{error_message}"
  @logger.info "\nRun #{"bridgetown webpack enable-postcss".bold.blue} to set it up.\n"

  return
end

plugins = %w(postcss-easy-import postcss-mixins postcss-color-function cssnano)

say "Adding the following PostCSS plugins: #{plugins.join(' | ')}", :green
run "yarn add -D #{plugins.join(' ')}"

remove_file "postcss.config.js"
copy_file "#{TEMPLATE_PATH}/postcss.config.js", "postcss.config.js"

# rubocop:enable all
