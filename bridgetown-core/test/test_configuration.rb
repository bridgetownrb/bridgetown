# frozen_string_literal: true

require "helper"

class TestConfiguration < BridgetownUnitTest
  using Bridgetown::Refinements

  def test_config
    @test_config ||= {
      "root_dir"    => site_root_dir,
      "plugins_dir" => site_root_dir("plugins"),
      "source"      => source_dir,
      "destination" => dest_dir,
    }
  end

  def default_config_fixture(overrides = {})
    Bridgetown.configuration(test_config.merge(overrides))
  end

  context ".from" do
    should "create a Configuration object" do
      expect(Configuration.from({})).is_a?(Configuration)
    end

    should "merge input over defaults" do
      result = Configuration.from("source" => "blah")
      refute_equal result["source"], Configuration::DEFAULTS["source"]
      assert_equal File.expand_path("blah"), result["source"]
    end

    should "return a valid Configuration instance" do
      assert_instance_of Configuration, Configuration.from({})
    end

    should "add default collections" do
      result = Configuration.from({})
      expected = {
        "posts" => {
          "output"         => true,
          "sort_direction" => "descending",
        },
        "pages" => {
          "output" => true,
        },
        "data"  => {
          "output" => false,
        },
      }
      assert_equal expected, result["collections"]
    end

    should "allow indifferent access" do
      result = Configuration.from({})
      assert result[:collections][:posts][:output]
    end
  end

  context "the effective site configuration" do
    setup do
      @config = Configuration.from(
        "exclude" => %w(
          README.md Licence
        )
      )
    end

    should "always exclude node_modules" do
      assert_includes @config["exclude"], "node_modules"
    end

    should "always exclude Gemfile and related paths" do
      exclude = @config["exclude"]
      assert_includes exclude, "Gemfile"
      assert_includes exclude, "Gemfile.lock"
      assert_includes exclude, "gemfiles"
    end

    should "always exclude ruby vendor directories" do
      exclude = @config["exclude"]
      assert_includes exclude, "vendor/bundle/"
      assert_includes exclude, "vendor/cache/"
      assert_includes exclude, "vendor/gems/"
      assert_includes exclude, "vendor/ruby/"
    end

    should "always exclude default cache directories" do
      exclude = @config["exclude"]
      assert_includes exclude, ".sass-cache"
      assert_includes exclude, ".bridgetown-cache"
    end
  end

  context "#add_default_collections" do
    should "no-op if collections is nil" do
      result = Configuration.new(collections: nil).add_default_collections
      assert_nil result["collections"]
    end

    should "turn an array into a hash" do
      result = Configuration.new(collections: %w(methods)).add_default_collections
      assert_instance_of Configuration, result["collections"]
      assert_equal({}, result.collections["methods"])
    end

    should "forces posts to output" do
      result = Configuration.new(collections: { "posts" => { "output" => false } })
        .add_default_collections
      assert_equal true, result["collections"]["posts"]["output"]
    end
  end

  context "#read_config_file" do
    setup do
      @config = Configuration.new({ "source" => source_dir("empty.yml") })
    end

    should "not raise an error on empty files" do
      Bridgetown.logger.log_level = :warn
      Bridgetown::YAMLParser.stub :load_file, false do
        @config.read_config_file("empty.yml")
      end
      Bridgetown.logger.log_level = :info
    end
  end

  context "#read_config_files" do
    setup do
      @config = Configuration.new(source: source_dir)
    end

    should "continue to read config files if one is empty" do
      mock = Minitest::Mock.new
      mock.expect :call, false, [File.expand_path("empty.yml")]
      mock.expect :call, { "foo" => "bar" }, [File.expand_path("not_empty.yml")]

      Bridgetown.logger.log_level = :warn
      read_config = nil
      Bridgetown::YAMLParser.stub :load_file, mock do
        read_config = @config.read_config_files(%w(empty.yml not_empty.yml))
      end
      Bridgetown.logger.log_level = :info

      assert_equal "bar", read_config["foo"]
      mock.verify
    end
  end

  context "#check_include_exclude" do
    setup do
      @config = Configuration.new({
        "auto"        => true,
        "watch"       => true,
        "server"      => true,
        "pygments"    => true,
        "layouts"     => true,
        "data_source" => true,
        "gems"        => [],
      })
    end

    should "raise an error if `exclude` key is a string" do
      config = Configuration.new(exclude: "READ-ME.md, Gemfile,CONTRIBUTING.hello.markdown")
      assert_raises(Bridgetown::Errors::InvalidConfigurationError) { config.check_include_exclude }
    end

    should "raise an error if `include` key is a string" do
      config = Configuration.new(include: "STOP_THE_PRESSES.txt,.heloses, .git")
      expect { config.check_include_exclude }.must_raise Bridgetown::Errors::InvalidConfigurationError
    end
  end

  context "loading configuration" do
    setup do
      @path = site_root_dir("bridgetown.config.yml")
      @user_config = File.join(Dir.pwd, "my_config_file.yml")
    end

    should "load configuration as hash" do
      assert_equal site_configuration, default_config_fixture
    end

    should "fire warning when user-specified config file isn't there" do
      assert_raises LoadError do
        Bridgetown.configuration("config" => [@user_config])
      end
    end
  end

  context "loading config from external file" do
    setup do
      @paths = {
        default: site_root_dir("bridgetown.config.yml"),
        other: site_root_dir("bridgetown_config.other.yml"),
      }
    end

    should "load different config if specified" do
      output = capture_output do
        Bridgetown::YAMLParser.stub :load_file, { "base_path" => "http://example.com" } do
          assert_equal \
            site_configuration(
              "base_path" => "http://example.com",
              "config"    => @paths[:other]
            ),
            default_config_fixture({ "config" => @paths[:other] })
        end
      end

      expect(output) << "Configuration file: #{@paths[:other]}"
    end

    should "load multiple config files" do
      output = capture_output do
        Bridgetown::YAMLParser.stub :load_file, {} do
          assert_equal(
            site_configuration(
              "config" => [@paths[:default], @paths[:other]]
            ),
            default_config_fixture({ "config" => [@paths[:default], @paths[:other]] })
          )
        end
      end

      expect(output)
        .include?("Configuration file: #{@paths[:default]}")
        .include?("Configuration file: #{@paths[:other]}")
    end

    should "load multiple config files and last config should win" do
      mock = Minitest::Mock.new
      mock.expect :call, { "base_path" => "http://example.dev" }, [@paths[:default]]
      mock.expect :call, { "base_path" => "http://example.com" }, [@paths[:other]]

      Bridgetown::YAMLParser.stub :load_file, mock do
        assert_equal \
          site_configuration(
            "base_path" => "http://example.com",
            "config"    => [@paths[:default], @paths[:other]]
          ),
          default_config_fixture({ "config" => [@paths[:default], @paths[:other]] })
      end
      mock.verify
    end
  end

  context "#merge_environment_specific_options!" do
    should "merge options in that are environment-specific" do
      conf = Configuration.new(Bridgetown::Configuration::DEFAULTS.deep_dup)
      refute conf["unpublished"]
      conf["test"] = { "unpublished" => true }
      conf.merge_environment_specific_options!
      assert conf["unpublished"]
      assert_nil conf["test"]
    end
  end

  context "#add_default_collections" do
    should "not do anything if collections is nil" do
      conf = Configuration.new(Bridgetown::Configuration::DEFAULTS.deep_dup).tap { |c| c["collections"] = nil }
      assert_equal conf.add_default_collections, conf
      assert_nil conf.add_default_collections["collections"]
    end

    should "converts collections to a hash if an array" do
      conf = Configuration.new(Bridgetown::Configuration::DEFAULTS.deep_dup).tap do |c|
        c["collections"] = ["docs"]
      end
      conf.add_default_collections
      assert conf.collections.posts.is_a?(Hash)
      assert conf.collections.docs.is_a?(Hash)
    end

    should "force collections.posts.output = true" do
      conf = Configuration.new(Bridgetown::Configuration::DEFAULTS.deep_dup).tap do |c|
        c["collections"] = { "posts" => { "output" => false } }
      end
      assert conf.add_default_collections.collections.posts.output
    end

    should "leave collections.posts.permalink alone if it is set" do
      posts_permalink = "/:year/:title/"
      conf = Configuration.new(Bridgetown::Configuration::DEFAULTS.deep_dup).tap do |c|
        c["collections"] = {
          "posts" => { "permalink" => posts_permalink },
        }
      end
      assert_equal posts_permalink, conf.add_default_collections.collections.posts.permalink
    end
  end

  context "folded YAML string" do
    setup do
      @tester = Configuration.new
    end

    should "ignore newlines in that string entirely from a sample file" do
      config = Bridgetown.configuration(
        @tester.read_config_file(
          site_root_dir("_config_folded.yml")
        )
      )
      assert_equal(
        "This string of text will ignore newlines till the next key.\n",
        config["folded_string"]
      )

      assert_equal(
        "This string of text will ignore newlines till the next key.",
        config["clean_folded_string"]
      )
    end

    should "ignore newlines in that string entirely from the template file" do
      config = Bridgetown.configuration(
        @tester.read_config_file(
          File.expand_path("../lib/site_template/src/_data/site_metadata.yml",
                           File.dirname(__FILE__))
        )
      )
      assert_includes config["description"], "an awesome description"
      refute_includes config["description"], "\n"
    end
  end

  context "initializers" do
    setup do
      @config = Configuration.from({})
      @config.initializers = {}

      @config.initializers[:something] =
        Bridgetown::Configuration::Initializer.new(
          name: :something,
          block: proc { |secret_value:|
            assert_equal secret_value, "shhh!"
          },
          completed: false
        )
    end

    should "affect the underlying configuration" do
      dsl = Configuration::ConfigurationDSL.new(scope: @config, data: @config)

      dsl.instance_variable_set(:@context, :testing)
      dsl.instance_exec(dsl) do |config|
        url "http://www.proddomain.com"

        only :testing do
          url "http://www.testdomain.com"

          init :something, require_gem: false do
            secret_value "shhh!"
          end
        end

        except :testing do
          url "http://www.fakedomain.com"
        end

        config.autoload_paths << "stuff"
      end

      assert_equal "http://www.testdomain.com", @config.url
      assert_equal "stuff", @config.autoload_paths.last

      assert @config.init_params.key?("something")
    end

    should "set the global timezone" do
      dsl = Configuration::ConfigurationDSL.new(scope: @config, data: @config)

      dsl.instance_variable_set(:@context, :testing)
      dsl.instance_exec(dsl) do
        timezone "GMT"
      end

      assert_equal "GMT", Bridgetown.timezone
    end
  end
end
