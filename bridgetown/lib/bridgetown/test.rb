# frozen_string_literal: true

# This file can be required by project test suites to set up the Minitest environment

require "bridgetown"

ENV["BRIDGETOWN_NO_BUNDLER_REQUIRE"] = nil
Bridgetown.begin!

Bridgetown::Builders::PluginBuilder.then do
  Bridgetown::Builders::DSL::Inspectors.setup_nokolexbor
end

require "bridgetown-core/rack/boot"

Bridgetown::Current.preloaded_configuration = Bridgetown.configuration
Bridgetown::Rack.boot

require "rack/test"

Bridgetown::Foundation::IntuitiveExpectations.enrich Minitest

Minitest::Spec::DSL::InstanceMethods.class_eval do
  # @!method expect
  #   Takes a value
  #   @return [Minitest::Expectation]
end

Minitest::Expectation.class_eval do
  # @!parse include Bridgetown::Foundation::IntuitiveExpectations
end

class Bridgetown::Test < Minitest::Test
  # @!parse include Minitest::Spec::DSL::InstanceMethods
  # @!parse extend Minitest::Spec::DSL::InstanceMethods

  extend Minitest::Spec::DSL
  include Rack::Test::Methods

  attr_reader :document

  def roda_app_class = RodaApp

  def roda_log_level = Logger::WARN

  def app
    return @app if @app

    # Set the log level to warn so we don't see all the usual HTTP chatter when testing
    roda_app_class.opts[:common_logger].level = roda_log_level

    @app = roda_app_class.app
  end

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
