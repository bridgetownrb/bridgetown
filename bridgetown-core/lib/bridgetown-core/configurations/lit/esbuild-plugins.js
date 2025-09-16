// You can add "full-stack" esbuild plugins here that you wish to share between
// the frontend bundles and Lit SSR. Just import your plugins and add them and
// any additional configuration to the `plugins` array below.

// This plugin will let you import `.lit.css` files as sidecar stylesheets.
// Read https://www.bridgetownrb.com/docs/components/lit#sidecar-css-files for documentation.
import { litCssPlugin } from "esbuild-plugin-lit-css"
import postcss from "postcss"

const postcssrc = (await import("postcss-load-config")).default

export const plugins = [
  litCssPlugin({
    filter: /\.lit\.css$/,
    transform: async (css, { filePath }) => {
      const postCssConfig = await postcssrc()
      const postCssProcessor = postcss([...postCssConfig.plugins])

      const results = await postCssProcessor.process(css, { ...postCssConfig.options, from: filePath })
      return results.css
    }
  }),
]
