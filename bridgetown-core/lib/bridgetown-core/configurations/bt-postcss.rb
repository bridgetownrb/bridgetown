# frozen_string_literal: true

# rubocop:disable all

TEMPLATE_PATH = File.expand_path("./bt-postcss", __dir__)

unless File.exist?("postcss.config.js")
  error_message = "#{"postcss.config.js".bold} not found. Please configure postcss in your project."

  @logger.error "\nError:".red, "🚨 #{error_message}"
  @logger.info "\nRun #{"bridgetown webpack enable-postcss".bold.blue} to set it up.\n"

  return
end

confirm = ask "This configuration will ovewrite your existing #{"postcss.config.js".bold.white}. Would you like to continue? [Yn]"
return unless confirm.upcase == "Y"

plugins = %w(postcss-easy-import postcss-mixins postcss-color-function cssnano)

say "Adding the following PostCSS plugins: #{plugins.join(' | ')}", :green
run "yarn add -D #{plugins.join(' ')}"

copy_file "#{TEMPLATE_PATH}/postcss.config.js", "postcss.config.js", force: true

# rubocop:enable all
