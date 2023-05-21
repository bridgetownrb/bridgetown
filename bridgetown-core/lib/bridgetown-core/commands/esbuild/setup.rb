# frozen_string_literal: true

template "esbuild.defaults.js.erb", "config/esbuild.defaults.js"
copy_file "jsconfig.json"
copy_file "esbuild.config.js", force: true
