# frozen_string_literal: true

# rubocop:disable all

unless File.exist?("postcss.config.js")
  error_message = "#{"postcss.config.js".bold} not found. Please configure postcss in your project."

  @logger.error "\nError:".red, "🚨 #{error_message}"
  @logger.info "\nRun #{"bridgetown webpack enable-postcss".bold.blue} to set it up.\n"

  return
end

say_status :tailwind, "Installing Tailwind CSS..."

confirm = ask "This configuration will ovewrite your existing #{"postcss.config.js".bold.white}. Would you like to continue? [Yn]"
return unless confirm.casecmp?("Y")

run "yarn add -D tailwindcss"
run "npx tailwindcss init"

gsub_file "tailwind.config.js", "purge: [],", <<~JS.strip
  purge: [
      './src/**/*.{html,md,liquid,erb,serb}',
      './frontend/javascript/**/*.js',
    ],
JS

copy_file in_templates_dir("postcss.config.js"), "postcss.config.js", force: true

if File.exist?("frontend/styles/index.css")
  prepend_to_file "frontend/styles/index.css",
                  File.read(in_templates_dir("css_imports.css"))
else
  say "\nPlease add the following lines to your CSS index file:"
  say File.read(in_templates_dir("/css_imports.css"))
end

say_status :tailwind, "Tailwind CSS is now configured."
say_status :tailwind, "When you deploy, ensure NODE_ENV is set to `production` so unused classes are purged from the output CSS bundle."

# rubocop:enable all
