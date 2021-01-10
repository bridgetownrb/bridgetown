TEMPLATE_PATH = File.expand_path("./tailwindcss", __dir__)

begin
  find_in_source_paths("postcss.config.js")
rescue Thor::Error
  error_message = "#{"postcss.config.js".bold} not found. Please configure postcss in your project."
  
  @logger.error "\nError:".red, "🚨 #{error_message}"
  @logger.info "\nFor new projects, you can use #{"bridgetown new my_project --use-postcss".bold.blue}\n"
  
  return
end

run "yarn add -D tailwindcss"
run "npx tailwindcss init"

remove_file "postcss.config.js"
copy_file "#{TEMPLATE_PATH}/postcss.config.js", "postcss.config.js"

prepend_to_file "frontend/styles/index.css",
                File.read("#{TEMPLATE_PATH}/css_imports.css")

run "bundle exec bridgetown configure purgecss"