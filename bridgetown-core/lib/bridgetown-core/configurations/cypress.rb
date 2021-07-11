# frozen_string_literal: true

# rubocop:disable Style/RegexpLiteral

# Install packages

packages = %w(cypress start-server-and-test)
say "Adding the following yarn packages: #{packages.join(" | ")}", :green
run "yarn add -D #{packages.join(" ")}"

# Copy cypress files and scripts into place

copy_file in_templates_dir("cypress.json"), "cypress.json"

cypress_scripts = File.read(in_templates_dir("cypress_scripts"))
script_regex = /"scripts": {(\s+".*,?)*/
inject_into_file("package.json", ",\n" + cypress_scripts, after: script_regex)

directory in_templates_dir("cypress_dir"), "cypress"

# rubocop:enable Style/RegexpLiteral
