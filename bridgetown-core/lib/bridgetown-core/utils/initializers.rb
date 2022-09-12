# frozen_string_literal: true

Bridgetown.initializer :dotenv do |config|
  Bridgetown.load_dotenv root: config.root_dir
end

Bridgetown.initializer :ssr do |config, setup: nil|
  config.roda do |app|
    app.plugin(:bridgetown_ssr, &setup)
  end
end

Bridgetown.initializer :parse_routes do |config|
  # This builds upon the work done here:
  # https://github.com/jeremyevans/roda-route_list/blob/master/bin/roda-parse_routes

  require "roda-route_parser"

  route_files = Dir["#{config.root_dir}/server/**/*.rb"]
  if config.key?(:routes)
    config.routes.source_paths.each do |routes_dir|
      routes_dir = File.expand_path(routes_dir, config.source)
      route_files += Dir["#{routes_dir}/**/*.*"]
    end
  end

  parser = RodaRouteParser.new
  json_gen_opts = { indent: "  ", space: " ", object_nl: "\n", array_nl: "\n" }

  routing_tree = []

  route_files.each do |route_file|
    file_contents = File.read(route_file)
    routes = parser.parse(file_contents)

    next unless routes.present?

    routes.each do |route|
      route["file"] = route_file
    end
    routing_tree += routes
  end

  File.write(File.join(config.root_dir, ".routes.json"), routing_tree.to_json(json_gen_opts))
end
