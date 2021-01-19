module.exports = {
  plugins: {
    'postcss-easy-import': {},
    'postcss-mixins': {},
    'postcss-color-function': {},
    'postcss-flexbugs-fixes': {},
    'postcss-preset-env': {
      autoprefixer: {
        flexbox: 'no-2009'
      },
      stage: 2,
      features: {
        'nesting-rules': true,
        'custom-media-queries': true
      },
    },
    'cssnano' : {
      preset: 'default'
    }
  }
}
