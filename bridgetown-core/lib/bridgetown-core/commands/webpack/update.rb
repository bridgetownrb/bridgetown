# frozen_string_literal: true

required_packages = %w(esbuild esbuild-loader)
redundant_packages = %w(@babel/core @babel/plugin-proposal-class-properties @babel/plugin-proposal-decorators @babel/plugin-transform-runtime @babel/preset-env babel-loader)

template "webpack.defaults.js.erb", "config/webpack.defaults.js", force: true
say "🎉 Webpack configuration updated successfully!"

return if Bridgetown.environment.test?

say "Installing required packages"
run "yarn add -D #{required_packages.join(' ')}"

packages_to_remove = self.package_json["devDependencies"].slice(*redundant_packages).keys
unless packages_to_remove.empty?
  confirm = ask "\nThe following packages will be removed: \n\n#{packages_to_remove.join("\n")}\n\nWould you like to continue? [Yn]"
  return unless confirm.casecmp?("Y")

  run "yarn remove #{packages_to_remove.join(' ')}"
end