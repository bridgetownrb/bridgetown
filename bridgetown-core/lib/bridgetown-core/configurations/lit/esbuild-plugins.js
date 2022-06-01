// You can add "full-stack" esbuild plugins here that you wish to share between
// the frontend bundles and Lit SSR. Just import your plugins and add them and
// any additional configuration to the `plugins` array below.

// This plugin will let you import `.lit.css` files as sidecar stylesheets.
// Read https://edge.bridgetownrb.com/docs/components/lit#sidecar-css-files for documentation.
const { litCssPlugin } = require("esbuild-plugin-lit-css")
const postCssConfig = require("postcss-load-config").sync()
const postCssProcessor = require("postcss")([...postCssConfig.plugins])

module.exports = {
  plugins: [
    litCssPlugin({
      filter: /\.lit\.css$/,
      transform: async (css, { filePath }) => {
        const results = await postCssProcessor.process(css, { ...postCssConfig.options, from: filePath })
        return results.css
      }
    }),
  ]
}
