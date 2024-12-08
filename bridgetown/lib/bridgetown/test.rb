# frozen_string_literal: true

# This file can be required by project test suites to set up the Minitest environment

require "bridgetown"

ENV["BRIDGETOWN_NO_BUNDLER_REQUIRE"] = nil
Bridgetown.begin!

Bridgetown::Builders::PluginBuilder.then do
  Bridgetown::Builders::DSL::Inspectors.setup_nokolexbor
end

require "bridgetown-core/rack/boot"
class Bridgetown::Rack::Logger
  def add(*)
    super if ENV["SERVER_LOGS"] == "true"
  end
end

Bridgetown::Current.preloaded_configuration = Bridgetown.configuration
Bridgetown::Rack.boot

require "rack/test"

class Bridgetown::Test < Minitest::Test
  include Rack::Test::Methods

  attr_reader :document

  def roda_app_class = RodaApp

  def app = roda_app_class.app

  def site
    roda_app_class.opts[:bridgetown_site]
  end

  def html(request) = @document = Nokolexbor::Document.parse(request.body)

  def json(request) = @document = JSON.parse(request.body)

  def routes = JSON.parse(File.read(
                            File.join(Bridgetown::Current.preloaded_configuration.root_dir,
                                      ".routes.json")
                          ))
end
