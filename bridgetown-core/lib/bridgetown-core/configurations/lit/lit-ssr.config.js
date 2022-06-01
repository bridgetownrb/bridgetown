const build = require("bridgetown-lit-renderer/build")
const { plugins } = require("./esbuild-plugins.js")

const esbuildOptions = { plugins }

build(esbuildOptions)
