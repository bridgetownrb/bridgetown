# frozen_string_literal: true

@render_service_name = ask "What would like to call your Render service?"
template in_templates_dir("render.yaml.erb"), "render.yaml"

say "All done. Just create a new blueprint from the Render dashboard and connect this repo."
