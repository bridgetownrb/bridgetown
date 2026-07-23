# frozen_string_literal: true

require "helper"

# rubocop:disable Lint/ConstantDefinitionInBlock
class TestRackServer < BridgetownUnitTest
  it "auto detects a supported server" do
    server = Bridgetown::Rack::Server.new

    assert server.name
  end

  it "sets up Puma automatically" do
    PumaServer = Bridgetown::Rack::Server.dup
    PumaServer.define_method(:supported_servers) { [:Puma] }

    server = PumaServer.new

    assert_equal "puma", server.name
    assert_match(%r{puma}, server.command.join(" "))
  end

  it "sets up Falcon automatically" do
    FalconServer = Bridgetown::Rack::Server.dup
    FalconServer.define_method(:supported_servers) { [:Falcon] }

    server = FalconServer.new

    assert_equal "falcon", server.name
    assert_match(%r{falcon serve}, server.command.join(" "))
  end

  it "raises an error when no supported servers are found" do
    UnsupportedServer = Bridgetown::Rack::Server.dup
    UnsupportedServer.define_method(:supported_servers) { [] }

    assert_raises do
      UnsupportedServer.new
    end
  end

  it "doesn't define missing methods after configuration" do
    server = Bridgetown::Rack::Server.new

    assert_raises do
      server.this_method_doesnt_exist
    end
  end

  describe "configured with Puma" do
    before do
      config_path = File.expand_path("fixtures/puma_web_server.rb", __dir__)
      @server = Bridgetown::Rack::Server.new(config_path)
    end

    it "reads the config file" do
      assert_equal :puma,               @server.name
      assert_equal 3000,                @server.port
      assert_equal "tcp://0.0.0.0",     @server.bind
    end

    it "includes the default Puma environment" do
      assert @server.class.ancestors.include?(Bridgetown::Rack::Environment::Puma)
    end
  end

  describe "configured with Falcon" do
    before do
      config_path = File.expand_path("fixtures/falcon_web_server.rb", __dir__)
      @server = Bridgetown::Rack::Server.new(config_path)
    end

    it "reads the config file" do
      assert_equal :falcon,             @server.name
      assert_equal 3000,                @server.port
      assert_equal "http://0.0.0.0",    @server.bind
    end

    it "includes the default Falcon environment" do
      assert @server.class.ancestors.include?(Bridgetown::Rack::Environment::Falcon)
    end
  end
end
# rubocop:enable Lint/ConstantDefinitionInBlock
