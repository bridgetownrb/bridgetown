# frozen_string_literal: true

TEMPLATE_PATH = File.expand_path("./render", __dir__)

@render_service_name = ask "What would like to call your Render service?"
template "#{TEMPLATE_PATH}/render.yaml.erb", "render.yaml"

say "All done. Just create a new blueprint from the Render dashboard and connect this repo."
