# frozen_string_literal: true

TEMPLATE_PATH = File.expand_path("./netlify", __dir__)

copy_file "#{TEMPLATE_PATH}/netlify.toml", "netlify.toml"
copy_file "#{TEMPLATE_PATH}/netlify.sh", "bin/netlify.sh"
`chmod a+x ./bin/netlify.sh`
