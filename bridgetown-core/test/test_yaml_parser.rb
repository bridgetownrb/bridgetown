# frozen_string_literal: true

require "helper"

class TestYAMLParser < BridgetownUnitTest
  class CustomYAMLSerializable
    def initialize
      @lorem = "ipsum"
    end
  end

  context "parsing YAML" do
    should "successfully parse a Date object" do
      yaml = "date: 2020-05-14"

      parsed_yaml = Bridgetown::YAMLParser.load(yaml)
      assert_equal Date, parsed_yaml["date"].class
    end

    should "successfully parse a Time object" do
      yaml = "time: 2019-07-14 19:22:00 +0100"

      parsed_yaml = Bridgetown::YAMLParser.load(yaml)
      assert_equal Time, parsed_yaml["time"].class
    end

    should "successfully parse a Rb object" do
      yaml = <<~YAML
        rb: !ruby/string:Rb |
          21 * 2
      YAML

      parsed_yaml = Bridgetown::YAMLParser.load(yaml)
      assert_equal Rb, parsed_yaml["rb"].class
    end

    should "error when trying to parse types not on the allowlist" do
      assert_raises(Psych::DisallowedClass) do
        Bridgetown::YAMLParser.load(CustomYAMLSerializable.new.to_yaml)
      end
    end
  end

  context "parsing YAML from a file" do
    should "successfully parse Date, Time and Rb objects" do
      yaml_file = test_dir("fixtures", "allowed_yaml.yml")
      parsed_yaml = Bridgetown::YAMLParser.load_file(yaml_file)

      assert_equal Date, parsed_yaml["date"].class
      assert_equal Time, parsed_yaml["time"].class
      assert_equal Rb, parsed_yaml["rb"].class
    end

    should "error when trying to parse types not on the allowlist" do
      yaml_file = test_dir("fixtures", "disallowed_yaml.yml")

      assert_raises(Psych::DisallowedClass) do
        Bridgetown::YAMLParser.load_file(yaml_file)
      end
    end
  end
end
