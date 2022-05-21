const build = require("./config/esbuild.defaults.js")

// Update this if you need to configure a destination folder other than `output`
const outputFolder = "output"

const ruby2js = require("@ruby2js/esbuild-plugin")

const esbuildOptions = {
  entryPoints: ["frontend/javascript/index.js.rb"],
  target: "es2020",
  plugins: [
    ruby2js({
      eslevel: 2020,
      filters: ["camelCase", "functions", "lit", "esm", "return"]
    }),
  ],
  format: "esm",
  splitting: true
}

build(outputFolder, esbuildOptions)
