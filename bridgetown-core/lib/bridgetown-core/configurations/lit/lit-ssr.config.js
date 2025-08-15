import build from "bridgetown-lit-renderer/build"
import { plugins } from "./esbuild-plugins.js"

const esbuildOptions = { plugins }

build(esbuildOptions)
