module.exports = {  
  plugins: {
    'postcss-flexbugs-fixes': {},
    'postcss-preset-env': {
      autoprefixer: false,
      importFrom: 'frontend/styles/breakpoints.css',
      stage: 4,
      features: {
        'nesting-rules': true,
        'custom-media-queries': true
      },
    }
  }
}