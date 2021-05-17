# frozen_string_literal: true

TEMPLATE_PATH = File.expand_path("./tailwindcss", __dir__)

unless File.exist?("postcss.config.js")
  error_message = "#{"postcss.config.js".bold} not found. Please configure postcss in your project."

  @logger.error "\nError:".red, "🚨 #{error_message}"
  @logger.info "\nRun #{"bridgetown webpack enable-postcss".bold.blue} to set it up.\n"

  return
end

run "yarn add -D tailwindcss"
run "npx tailwindcss init"

remove_file "postcss.config.js"
copy_file "#{TEMPLATE_PATH}/postcss.config.js", "postcss.config.js"

prepend_to_file "frontend/styles/index.css",
                File.read("#{TEMPLATE_PATH}/css_imports.css")

run "bundle exec bridgetown configure purgecss"
