# frozen_string_literal: true

copy_file in_templates_dir("vercel.json"), "vercel.json"
copy_file in_templates_dir("vercel_url.rb"), "plugins/builders/vercel_url.rb"
