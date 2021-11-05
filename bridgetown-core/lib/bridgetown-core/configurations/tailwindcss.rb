# frozen_string_literal: true

# rubocop:disable all

unless File.exist?("postcss.config.js")
  error_message = "#{"postcss.config.js".bold} not found. Please configure postcss in your project."

  @logger.error "\nError:".red, "🚨 #{error_message}"
  @logger.info "\nRun #{"bridgetown webpack enable-postcss".bold.blue} to set it up.\n"

  return
end

confirm = ask "This configuration will ovewrite your existing #{"postcss.config.js".bold.white}. Would you like to continue? [Yn]"
return unless confirm.casecmp?("Y")

run "yarn add -D tailwindcss"
run "npx tailwindcss init"

copy_file in_templates_dir("postcss.config.js"), "postcss.config.js", force: true

run "bundle exec bridgetown configure purgecss"

if File.exist?("frontend/styles/index.css")
  prepend_to_file "frontend/styles/index.css",
                  File.read(in_templates_dir("css_imports.css"))
else
  say "\nPlease add the following lines to your CSS index file:"
  say File.read(in_templates_dir("/css_imports.css"))
end

# rubocop:enable all
