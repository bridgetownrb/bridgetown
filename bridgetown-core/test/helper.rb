# frozen_string_literal: true

$VERBOSE = nil

ENV["BRIDGETOWN_ENV"] = "test"

if ENV["CI"]
  require "simplecov"
  SimpleCov.start
elsif !ENV["SKIP_COV"]
  require File.expand_path("simplecov_custom_profile", __dir__)
  SimpleCov.start "gem" do
    add_filter "/vendor/gem"
    add_filter "/vendor/bundle"
    add_filter ".bundle"
  end
end

require "nokogiri"
require "rubygems"
require "ostruct"
require "minitest/autorun"
require "minitest/reporters"
require "minitest/profile"
require "rspec/mocks"
require_relative "../lib/bridgetown-core.rb"
require_relative "../lib/bridgetown-core/commands/base.rb"

Bridgetown.logger = Logger.new(StringIO.new, :error)

require "kramdown"
require "shoulda"

include Bridgetown

require "bridgetown-core/commands/serve/servlet"

# Report with color.
Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new(
    color: true
  ),
]

module Minitest::Assertions
  def assert_exist(filename, msg = nil)
    msg = message(msg) { "Expected '#{filename}' to exist" }
    assert File.exist?(filename), msg
  end

  def refute_exist(filename, msg = nil)
    msg = message(msg) { "Expected '#{filename}' not to exist" }
    refute File.exist?(filename), msg
  end
end

module DirectoryHelpers
  def root_dir(*subdirs)
    File.expand_path(File.join("..", *subdirs), __dir__)
  end

  def dest_dir(*subdirs)
    test_dir("dest", *subdirs)
  end

  def site_root_dir(*subdirs)
    test_dir("source", *subdirs)
  end

  def resources_root_dir(*subdirs)
    test_dir("resources", *subdirs)
  end

  def source_dir(*subdirs)
    test_dir("source", "src", *subdirs)
  end

  def test_dir(*subdirs)
    root_dir("test", *subdirs)
  end

  def temp_dir(*subdirs)
    if Utils::Platforms.windows?
      drive = Dir.pwd.sub(%r!^([^\/]+).*!, '\1')
      temp_root = File.join(drive, "tmp")
    else
      temp_root = "/tmp"
    end

    File.join(temp_root, *subdirs)
  end
end

class BridgetownUnitTest < Minitest::Test
  include ::RSpec::Mocks::ExampleMethods
  include DirectoryHelpers
  extend DirectoryHelpers

  def mu_pp(obj)
    s = obj.is_a?(Hash) ? JSON.pretty_generate(obj) : obj.inspect
    s = s.encode Encoding.default_external if defined? Encoding
    s
  end

  def mocks_expect(*args)
    RSpec::Mocks::ExampleMethods::ExpectHost.instance_method(:expect)\
      .bind(self).call(*args)
  end

  def before_setup
    RSpec::Mocks.setup
    super
  end

  def after_teardown
    super
    RSpec::Mocks.verify
  ensure
    RSpec::Mocks.teardown
  end

  def fixture_document(relative_path)
    site = fixture_site(
      "collections" => {
        "methods" => {
          "output" => true,
        },
      }
    )
    site.read
    matching_doc = site.collections["methods"].docs.find do |doc|
      doc.relative_path == relative_path
    end
    [site, matching_doc]
  end

  def fixture_site(overrides = {})
    Bridgetown::Site.new(site_configuration(overrides))
  end

  def resources_site(overrides = {})
    overrides["content_engine"] = "resource"
    new_config = site_configuration(overrides)
    new_config.root_dir = resources_root_dir
    new_config.source = resources_root_dir("src")
    new_config.plugins_dir = resources_root_dir("plugins")
    Bridgetown::Site.new new_config
  end

  def default_configuration
    Marshal.load(Marshal.dump(Bridgetown::Configuration::DEFAULTS))
  end

  def build_configs(overrides, base_hash = default_configuration)
    Utils.deep_merge_hashes(base_hash, overrides)
  end

  def load_plugin_content
    unless @plugin_loaded
      Bridgetown::PluginManager.new_source_manifest(
        origin: self,
        components: test_dir("plugin_content", "components"),
        content: test_dir("plugin_content", "content"),
        layouts: test_dir("plugin_content", "layouts")
      )
    end
    @plugin_loaded ||= true
  end

  def site_configuration(overrides = {})
    load_plugin_content

    full_overrides = build_configs(overrides, build_configs(
                                                "destination" => dest_dir,
                                                "plugins_dir" => site_root_dir("plugins"),
                                                "incremental" => false
                                              ))
    Configuration.from(full_overrides.merge(
                         "root_dir" => site_root_dir,
                         "source"   => source_dir
                       ))
  end

  def clear_dest
    FileUtils.rm_rf(dest_dir)
    FileUtils.rm_rf(site_root_dir(".bridgetown-metadata"))
  end

  def directory_with_contents(path)
    FileUtils.rm_rf(path)
    FileUtils.mkdir(path)
    File.open("#{path}/index.html", "w") { |f| f.write("I was previously generated.") }
  end

  def with_env(key, value)
    old_value = ENV[key]
    ENV[key] = value
    yield
    ENV[key] = old_value
  end

  def capture_output(level = :debug)
    $stdout = buffer = StringIO.new
    Bridgetown.logger = Logger.new(buffer)
    Bridgetown.logger.log_level = level
    yield
    buffer.rewind
    buffer.string.to_s
  ensure
    $stdout = STDOUT
    Bridgetown.logger = Logger.new(StringIO.new, :error)
  end
  alias_method :capture_stdout, :capture_output
  alias_method :capture_stderr, :capture_output

  def nokogiri_fragment(str)
    Nokogiri::HTML.fragment(
      str
    )
  end

  def skip_if_windows(msg = nil)
    if Utils::Platforms.really_windows?
      msg ||= "Bridgetown does not currently support this feature on Windows."
      skip msg.to_s.magenta
    end
  end

  def symlink_if_allowed(target, sym_file)
    FileUtils.ln_sf(target, sym_file)
  rescue Errno::EACCES
    skip "Permission denied for creating a symlink to #{target.inspect} " \
         "on this machine".magenta
  rescue NotImplementedError => e
    skip e.to_s.magenta
  end
end

class FakeLogger
  def <<(str); end
end

module TestWEBrick
  module_function

  def mount_server(&block)
    server = WEBrick::HTTPServer.new(config)

    begin
      server.mount("/", Bridgetown::Commands::Serve::Servlet, document_root,
                   document_root_options)

      server.start
      addr = server.listeners[0].addr
      block.yield([server, addr[3], addr[1]])
    rescue StandardError => e
      raise e
    ensure
      server.shutdown
      sleep 0.1 until server.status == :Stop
    end
  end

  def config
    logger = FakeLogger.new
    {
      BindAddress: "127.0.0.1", Port: 0,
      ShutdownSocketWithoutClose: true,
      ServerType: Thread,
      Logger: WEBrick::Log.new(logger),
      AccessLog: [[logger, ""]],
      BridgetownOptions: {},
    }
  end

  def document_root
    "#{File.dirname(__FILE__)}/fixtures/webrick"
  end

  def document_root_options
    WEBrick::Config::FileHandler.merge(
      FancyIndexing: true,
      NondisclosureName: [
        ".ht*", "~*",
      ]
    )
  end
end
