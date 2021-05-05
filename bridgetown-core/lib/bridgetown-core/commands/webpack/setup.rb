# frozen_string_literal: true

template "webpack.defaults.js.erb", "webpack.defaults.js"
copy_file "webpack.config.js", force: true
