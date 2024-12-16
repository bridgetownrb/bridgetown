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
require "minitest/stub_any_instance"
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

module IntuitiveExpectations
  def true?(msg = nil)
    must_be(:itself, Minitest::Assertions::UNDEFINED, msg)
    self
  end

  def false?(msg = nil)
    wont_be(:itself, Minitest::Assertions::UNDEFINED, msg)
    self
  end

  def ==(other)
    must_equal(other)
    self
  end

  def !=(other)
    must_not_equal(other)
    self
  end

  def nil?(msg = nil)
    must_be_nil(msg)
    self
  end

  def not_nil?(msg = nil)
    wont_be_nil(msg)
    self
  end

  def empty?(msg = nil)
    must_be_empty(msg)
    self
  end

  def filled?(msg = nil)
    wont_be_empty(msg)
    self
  end

  def include?(other, msg = nil)
    must_include(other, msg)
    self
  end
  alias_method :<<, :include?

  def exclude?(other, msg = nil)
    wont_include(other, msg)
    self
  end

  def =~(other)
    must_match(other)
    self
  end

  def is_a?(klass, msg = nil)
    must_be_instance_of(klass, msg)
    self
  end
end
Minitest::Expectation.include IntuitiveExpectations
Minitest.backtrace_filter.add_filter %r!bridgetown-core/test/helper\.rb!

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
  include Minitest::Spec::DSL::InstanceMethods
  include DirectoryHelpers
  extend DirectoryHelpers

  # Uncomment this if you need better printed output when debugging test failures:
  # make_my_diffs_pretty!

  def after_teardown # rubocop:disable Lint/UselessMethodDefinition
    super
    # Uncomment for debugging purposes:
    # unless self.class.instance_variable_get(:@already_torn)
    #   self.class.instance_variable_set(:@already_torn, true)
    #   puts self.class
    # end
  end

  def fixture_site(overrides = {})
    Bridgetown::Site.new(site_configuration(overrides))
  end

  def resources_site(overrides = {})
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

  def reset_i18n_config
    I18n.enforce_available_locales = false
    I18n.locale = nil
    I18n.default_locale = nil
    I18n.load_path = Gem.find_files_from_load_path("active_support/locale/en.*") # restore basic translations
    I18n.available_locales = nil
    I18n.backend = nil
    I18n.default_separator = nil
    I18n.enforce_available_locales = true
    I18n.fallbacks = nil if I18n.respond_to?(:fallbacks=)
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
