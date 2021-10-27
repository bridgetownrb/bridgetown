# frozen_string_literal: true

# rubocop:disable Style/RegexpLiteral

# Install packages

say "Installing Cypress...", :green
run "yarn add -D cypress"

# Copy cypress files and tasks into place
cypress_tasks = File.read(in_templates_dir("cypress_tasks.rake"))

copy_file in_templates_dir("cypress.json"), "cypress.json"
inject_into_file("Rakefile", "\n" + cypress_tasks)
directory in_templates_dir("cypress_dir"), "cypress"

# rubocop:enable Style/RegexpLiteral
