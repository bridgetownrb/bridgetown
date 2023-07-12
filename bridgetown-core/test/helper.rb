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
require "nokolexbor"
require "rubygems"
require "ostruct"
require "minitest/autorun"
require "minitest/reporters"
require "minitest/profile"
require "rspec/mocks"
require_relative "../lib/bridgetown-core"
require_relative "../lib/bridgetown-core/commands/base"

Bridgetown.logger = Logger.new(StringIO.new, :error)

require "kramdown"
require "shoulda"

include Bridgetown

# Report with color. ::DefaultReporter
# Switch to Minitest::Reporters::SpecReporter if you want detailed
# test output!
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

  def assert_file_contains(regex, filename)
    assert_exist filename

    file_contents = File.read(filename)
    assert_match regex, file_contents
  end

  def refute_file_contains(regex, filename)
    assert_exist filename

    file_contents = File.read(filename)
    refute_match regex, file_contents
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
    RSpec::Mocks::ExampleMethods::ExpectHost.instance_method(:expect)
      .bind_call(self, *args)
  end

  def before_setup
    RSpec::Mocks.setup
    super
  end

  def after_teardown
    super
    # Uncomment for debugging purposes:
    # unless self.class.instance_variable_get(:@already_torn)
    #   self.class.instance_variable_set(:@already_torn, true)
    #   puts self.class
    # end
    RSpec::Mocks.verify
  ensure
    RSpec::Mocks.teardown
  end

  def fixture_site(overrides = {})
    Bridgetown::Site.new(site_configuration(overrides))
  end

  def resources_site(overrides = {})
    overrides["content_engine"] = "resource"
    overrides["available_locales"] ||= %w[en fr]
    overrides["plugins_dir"] = resources_root_dir("plugins")
    new_config = site_configuration(overrides)
    new_config.root_dir = resources_root_dir
    new_config.source = resources_root_dir("src")
    Bridgetown::Site.new new_config
  end

  def load_plugin_content(config)
    config.source_manifests << Bridgetown::Configuration::SourceManifest.new(
      origin: self.class,
      components: test_dir("plugin_content", "components"),
      content: test_dir("plugin_content", "content"),
      layouts: test_dir("plugin_content", "layouts")
    )
  end

  def site_configuration(overrides = {})
    Bridgetown.reset_configuration!

    load_plugin_content(Bridgetown::Current.preloaded_configuration)

    full_overrides = Utils.deep_merge_hashes({ "destination" => dest_dir,
                                               "plugins_dir" => site_root_dir("plugins"), }, overrides)

    Bridgetown.configuration(full_overrides.merge(
                               "root_dir"          => site_root_dir,
                               "source"            => source_dir,
                               "skip_config_files" => true
                             ))
  end

  def clear_dest
    FileUtils.rm_rf(dest_dir)
    FileUtils.rm_rf(site_root_dir(".bridgetown-metadata"))
  end

  def directory_with_contents(path)
    FileUtils.rm_rf(path)
    FileUtils.mkdir(path)
    File.write("#{path}/index.html", "I was previously generated.")
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

# stub
module Bridgetown
  module Paginate
    class PaginationIndexer
      def self.index_documents_by(pages_list, search_term)
        # site.collections[@configured_collection].resources

        pages_list.to_h do |resource|
          [resource.data[search_term], nil]
        end
      end
    end
  end
end
