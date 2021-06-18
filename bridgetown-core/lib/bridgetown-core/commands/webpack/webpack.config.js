var config = require("./config/webpack.defaults.js")
const { merge } = require('webpack-merge')

// Add any overrides to the default webpack config here:
//
// Eg:
//
//  ```
//    const path = require("path")
//    config.resolve.modules.push(path.resolve(__dirname, 'frontend', 'components'))
//    config.resolve.alias.frontendComponents = path.resolve(__dirname, 'frontend', 'components')
//  ```
//
// You can also merge in custom config using the included `webpack-merge` package.
// Complete docs available at: https://github.com/survivejs/webpack-merge
//
// Eg:
//
//  ```
//    const customConfig = { ..... }
//    config = merge(config, customConfig)
//  ```





////////////////////////////////////////////////////////

module.exports = config