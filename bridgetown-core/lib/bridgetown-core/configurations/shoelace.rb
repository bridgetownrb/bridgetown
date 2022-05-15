# frozen_string_literal: true

say_status :shoelace, "Installing Shoelace..."

run "yarn add @shoelace-style/shoelace"

say 'Adding Shoelace to "frontend/javascript/index.js"...', :magenta

javascript_import do
  <<~JS
    // Import the base Shoelace stylesheet:
    import "@shoelace-style/shoelace/dist/themes/light.css"

    // Example components, mix 'n' match however you like!
    import "@shoelace-style/shoelace/dist/components/button/button.js"
    import "@shoelace-style/shoelace/dist/components/icon/icon.js"
    import "@shoelace-style/shoelace/dist/components/spinner/spinner.js"

    // Use the public icons folder:
    import { setBasePath } from "@shoelace-style/shoelace/dist/utilities/base-path.js"
    setBasePath("/shoelace-assets")
  JS
end

say "Updating frontend build commands...", :magenta

if Bridgetown::Utils.frontend_bundler_type == :esbuild
  insert_into_file "package.json", before: '    "esbuild": "node' do
    <<-JS
    "shoelace:copy-assets": "mkdir -p src/shoelace-assets && cp -r node_modules/@shoelace-style/shoelace/dist/assets src/shoelace-assets",
    JS
  end
  gsub_file "package.json", %r{"esbuild": "node}, '"esbuild": "yarn shoelace:copy-assets && node'
  gsub_file "package.json", %r{"esbuild-dev": "node},
            '"esbuild-dev": "yarn shoelace:copy-assets && node'
else
  insert_into_file "package.json", before: '    "webpack-build": "webpack' do
    <<-JS
    "shoelace:copy-assets": "mkdir -p src/shoelace-assets && cp -r node_modules/@shoelace-style/shoelace/dist/assets src/shoelace-assets",
    JS
  end
  gsub_file "package.json", %r{"webpack-build": "webpack},
            '"webpack-build": "yarn shoelace:copy-assets && webpack'
  gsub_file "package.json", %r{"webpack-dev": "webpack},
            '"webpack-dev": "yarn shoelace:copy-assets && webpack'
end

say_status :shoelace, "Shoelace is now configured!"

say 'For further reading, check out "https://shoelace.style"', :blue
