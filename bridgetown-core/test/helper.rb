# frozen_string_literal: true

$VERBOSE = nil

ENV["BRIDGETOWN_ENV"] = "test"
ENV["MT_NO_EXPECTATIONS"] = "true"

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

include Bridgetown

# Switch to Minitest::Reporters::SpecReporter if you want detailed
# test output!
Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new(
    color: true,
    detailed_skip: !ENV["BYPASS_TEST_IN_FULL_SUITE"] # don't print out noisy skip messages in full suite
  ),
]

if ENV["BYPASS_TEST_IN_FULL_SUITE"]
  # monkey-patch so we don't get lots of annoying yellow "S" characters
  Minitest::Reporters::DefaultReporter.class_eval do
    def record_skip(record)
      # no-op
    end
  end
end

module Minitest::Assertions
  ####
  # TODO: we should remove these and use assert/refute_path_exists
  # https://docs.seattlerb.org/minitest/Minitest/Assertions.html#method-i-assert_path_exists
  def assert_exist(filename, msg = nil)
    msg = message(msg) { "Expected '#{filename}' to exist" }
    assert File.exist?(filename), msg
  end

  def refute_exist(filename, msg = nil)
    msg = message(msg) { "Expected '#{filename}' not to exist" }
    refute File.exist?(filename), msg
  end
  ####

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

Bridgetown::Foundation::IntuitiveExpectations.enrich Minitest

module DirectoryHelpers
  def root_dir(*subdirs)
    File.expand_path(File.join("..", *subdirs), __dir__)
  end

  def dest_dir(*subdirs)
    testing_dir("dest", *subdirs)
  end

  def site_root_dir(*subdirs)
    testing_dir("source", *subdirs)
  end

  def resources_root_dir(*subdirs)
    testing_dir("resources", *subdirs)
  end

  def source_dir(*subdirs)
    testing_dir("source", "src", *subdirs)
  end

  # Must not be named test_dir, or else the method isn't accessible in Minitest
  # spec (describe/it) blocks.
  def testing_dir(*subdirs)
    root_dir("test", *subdirs)
  end
end

Minitest::Spec::DSL::InstanceMethods.class_eval do
  # @!method expect
  #   Takes a value
  #   @return [Minitest::Expectation]
end

Minitest::Expectation.class_eval do
  # @!parse include Bridgetown::Foundation::IntuitiveExpectations
end

class BridgetownUnitTest < Minitest::Test
  # @!parse include Minitest::Spec::DSL::InstanceMethods
  # @!parse extend Minitest::Spec::DSL::InstanceMethods
  extend Minitest::Spec::DSL
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
      origin: Kernel.const_get(self.class.name.split("::").first), # because Minitest `describe` blocks are nested
      components: testing_dir("plugin_content", "components"),
      content: testing_dir("plugin_content", "content"),
      layouts: testing_dir("plugin_content", "layouts")
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

  # TODO: can we simplify this by utilizing Minitest's `capture_io`?
  # see: https://docs.seattlerb.org/minitest/Minitest/Assertions.html#method-i-capture_io
  def capture_output(level = :debug)
    orig_error = nil
    $stdout = buffer = StringIO.new
    Bridgetown.logger = Logger.new(buffer)
    Bridgetown.logger.log_level = level
    begin
      yield
    rescue Exception => e # rubocop:disable Lint/RescueException
      orig_error = e
    end
    $stdout = STDOUT
    Bridgetown.logger = Logger.new(StringIO.new, :error)
    buffer.rewind
    buffer.string.to_s.tap do |str|
      next unless orig_error

      puts str # rubocop:disable Bridgetown/NoPutsAllowed
      raise orig_error
    end
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
    I18n.load_path = Gem.find_files_from_load_path("bridgetown-core/locale/en.*") # restore basic translations
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
