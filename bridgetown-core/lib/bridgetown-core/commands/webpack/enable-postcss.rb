# frozen_string_literal: true

create_file "postcss.config.js"
template "webpack.defaults.js.erb", "webpack.defaults.js", force: true
