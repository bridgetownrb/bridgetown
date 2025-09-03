# frozen_string_literal: true

@render_service_name = ask "What would like to call your Render service?"
template in_templates_dir("render.yaml.erb"), "render.yaml"

say_status :render, "Your render.yaml file is now configured!"
say ""
say "Verify its contents and once ready, create a new blueprint from the Render dashboard"
say "and connect your repo."
say ""
say "Optionally, if you're setting up a backend API and database, create a environment group"
say "on Render called [yourservicehere]-prod-envs for sharing environment variables between"
say "multiple servers."
