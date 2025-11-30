# frozen_string_literal: true

# Make sure you update REQUIRE_DENYLIST in `Bridgetown::Configuration` for initializers which
# aren't Gem backed

Bridgetown.initializer :dotenv do |config|
  Bridgetown.load_dotenv root: config.root_dir
end

Bridgetown.initializer :ssr do |config, setup: nil, **options|
  config.roda do |app|
    app.plugin(:bridgetown_ssr, options, &setup)
  end
end

Bridgetown.initializer :external_sources do |config, contents:|
  Bridgetown::ExternalSources = Module.new

  contents.each do |coll, path|
    contents[coll] = File.expand_path(path, config.root_dir)
  end

  if config.context == :static
    contents.each_value.each_with_index do |path, index|
      Bridgetown.logger.info(index == 0 ? "External Sources:" : "", path)
    end
  end

  config.source_manifest(
    origin: Bridgetown::ExternalSources,
    contents:,
    bare_text: true
  )

  contents.each_value do |path|
    config.additional_watch_paths << path
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

    next if routes.empty?

    routes.each do |route|
      route["file"] = route_file
    end
    routing_tree += routes
  end

  File.write(File.join(config.root_dir, ".routes.json"), routing_tree.to_json(json_gen_opts))
end
