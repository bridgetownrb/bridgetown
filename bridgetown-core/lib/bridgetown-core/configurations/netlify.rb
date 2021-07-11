# frozen_string_literal: true

copy_file in_templates_dir("netlify.toml"), "netlify.toml"
copy_file in_templates_dir("netlify.sh"), "bin/netlify.sh"
`chmod a+x ./bin/netlify.sh`
