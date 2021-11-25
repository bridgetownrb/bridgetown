const build = require("./config/esbuild.defaults.js")

// Update this if you need to configure a destination folder other than `output`
const outputFolder = "output"

// You can customize this as you wish, perhaps to add new esbuild plugins.
//
// Eg:
//
//  ```
//  const path = require("path")
//  const esbuildCopy = require('esbuild-plugin-copy').default
//  const esbuildOptions = {
//    plugins: [
//      esbuildCopy({
//        assets: {
//          from: [path.resolve(__dirname, 'node_modules/somepackage/files/*')],
//          to: [path.resolve(__dirname, 'output/_bridgetown/somepackage/files')],
//        },
//        verbose: false
//      }),
//    ]
//  }
//  ```
const esbuildOptions = {}

build(outputFolder, esbuildOptions)
