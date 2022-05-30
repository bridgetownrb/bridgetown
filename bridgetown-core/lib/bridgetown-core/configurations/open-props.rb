# frozen_string_literal: true

run "yarn add open-props"

variables_import = <<~CSS
  @import "variables.css";

CSS

if File.exist?("frontend/styles/index.css")
  prepend_to_file "frontend/styles/index.css", variables_import
elsif File.exist?("frontend/styles/index.scss")
  prepend_to_file "frontend/styles/index.scss", variables_import
else
  say "\nPlease add the following lines to your CSS index file:"
  say variables_import
end

template in_templates_dir("variables.css.erb"), "frontend/styles/variables.css"

say_status :open_props, "Open Props is now configured."
