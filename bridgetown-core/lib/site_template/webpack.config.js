const path = require('path');
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

module.exports = {
  entry: './frontend/javascript/index.js',
  devtool: "source-map",
  output: {
    path: path.resolve(__dirname, 'output', '_bridgetown', 'static', 'js'),
    filename: 'all.js'
  },
  resolve: {
    extensions: ['.js']
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: "../css/all.css",
    })
  ],
  module: {
    rules: [
      {
        test: /\.js/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: [
              '@babel/preset-env'
            ],
            plugins: [
              '@babel/plugin-proposal-class-properties'
            ]
          }
        }
      },
      {
        test: /\.(sc|c)ss$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          {
            loader: 'sass-loader',
            options: {
              sassOptions: {
                includePaths: [path.resolve(__dirname, 'src/_includes')]
              }
            }
          }
        ]
      },
      {
        test: /\.woff2?$|\.ttf$|\.eot$|\.svg$/,
        loader: 'file-loader',
        options: {
          outputPath: '../fonts',
          publicPath: '../fonts'
        },
      }
    ]
  }
};
