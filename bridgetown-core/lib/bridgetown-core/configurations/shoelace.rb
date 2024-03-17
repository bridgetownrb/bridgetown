# frozen_string_literal: true

say_status :shoelace, "Installing Shoelace..."

run "yarn add @shoelace-style/shoelace"

stylesheet_import = <<~CSS
  /* Import the base Shoelace stylesheet: */
  @import "@shoelace-style/shoelace/dist/themes/light.css";

CSS

if File.exist?("frontend/styles/index.css")
  prepend_to_file "frontend/styles/index.css", stylesheet_import
elsif File.exist?("frontend/styles/index.scss")
  prepend_to_file "frontend/styles/index.scss", stylesheet_import
else
  say "\nPlease add the following lines to your CSS index file:"
  say stylesheet_import
end

say 'Adding Shoelace to "frontend/javascript/index.js"...', :magenta

javascript_import do
  <<~JS

    // Example Shoelace components. Mix 'n' match however you like!
    import "@shoelace-style/shoelace/dist/components/button/button.js"
    import "@shoelace-style/shoelace/dist/components/icon/icon.js"
    import "@shoelace-style/shoelace/dist/components/spinner/spinner.js"

    // Use the public icons folder:
    import { setBasePath } from "@shoelace-style/shoelace/dist/utilities/base-path.js"
    setBasePath("/shoelace-assets")
  JS
end

say "Updating frontend build commands...", :magenta

insert_into_file "package.json", before: '    "esbuild": "node' do
  <<-JS
  "shoelace:copy-assets": "mkdir -p src/shoelace-assets && cp -r node_modules/@shoelace-style/shoelace/dist/assets src/shoelace-assets",
  JS
end
gsub_file "package.json", %r{"esbuild": "node}, '"esbuild": "yarn shoelace:copy-assets && node'
gsub_file "package.json", %r{"esbuild-dev": "node},
          '"esbuild-dev": "yarn shoelace:copy-assets && node'

if File.exist?(".gitignore")
  append_to_file ".gitignore" do
    <<~FILES

      src/shoelace-assets
    FILES
  end
end

say_status :shoelace, "Shoelace is now configured!"

say 'For further reading, check out "https://shoelace.style"', :blue
