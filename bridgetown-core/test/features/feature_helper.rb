# frozen_string_literal: true

require "helper"
require "yaml"
require "open3"

class BridgetownFeatureTest < BridgetownUnitTest
  class Paths
    SOURCE_DIR = Pathname.new(File.expand_path("../..", __dir__))

    def self.test_dir
      source_dir.join("tmp", "bridgetown")
    end

    def self.bridgetown_bin
      source_dir.join("bin", "bridgetown")
    end

    def self.source_dir
      SOURCE_DIR
    end

    def self.root_files
      [
        ".bridgetown-cache",
        ".bridgetown-cache/frontend-bundling",
        ".bridgetown-cache/frontend-bundling/manifest.json",
        "bridgetown.config.yml",
        "webpack.config.js",
        "esbuild.config.js",
        "config",
        "plugins",
        "plugins/nested",
        "plugins/nested/subnested",
        "frontend",
      ]
    end
  end

  def before_setup
    FileUtils.rm_rf(Paths.test_dir) if Paths.test_dir.exist?
    FileUtils.mkdir_p(Paths.test_dir) unless Paths.test_dir.directory?
    Dir.chdir(Paths.test_dir)
    @timezone_before_scenario = ENV["TZ"]

    super
  end

  def after_teardown
    FileUtils.rm_rf(Paths.test_dir) if Paths.test_dir.exist?
    Dir.chdir(Paths.test_dir.parent.parent)
    ENV["TZ"] = @timezone_before_scenario
  end

  ####

  def run_bridgetown(command, args = "", skip_status_check: false)
    args = args.strip.split # Shellwords?
    process, output = exec_command("ruby", Paths.bridgetown_bin.to_s, command, *args, "--trace")
    unless skip_status_check
      assert process.exitstatus.zero?, "Bridgetown process failed: #{process} \n#{output}"
    end

    [process, output]
  end

  def exec_command(*args)
    stdin, stdout, stderr, process = Open3.popen3(*args)
    out = stdout.read.strip
    err = stderr.read.strip

    [stdin, stdout, stderr].each(&:close)
    [process.value, out + err]
  end

  ####

  def create_directory(dir)
    if Paths.root_files.include?(dir)
      FileUtils.mkdir_p(dir)
    else
      dir_in_src = File.join("src", dir)
      FileUtils.mkdir_p(dir_in_src) unless File.directory?(dir_in_src)
    end
  end

  def create_file(file, text)
    if Paths.root_files.include?(file.split("/").first)
      File.write(file, text)
    else
      FileUtils.mkdir_p("src")
      File.write(File.join("src", file), text)
    end
  end

  def create_page(file, text, **front_matter)
    FileUtils.mkdir_p("src")

    File.write(File.join("src", file), <<~DATA)
      #{front_matter.deep_stringify_keys.to_yaml}
      ---

      #{text}
    DATA
  end

  def create_configuration(**config)
    File.write("bridgetown.config.yml", config.deep_stringify_keys.to_yaml.delete_prefix("---\n"))
  end

  def seconds_agnostic_time(time)
    time = time.strftime("%H:%M:%S") if time.is_a?(Time)
    hour, minutes, = time.split(":")
    "#{hour}:#{minutes}"
  end

  def setup_collections_fixture(directory = "")
    collections_dir = File.join(Paths.test_dir, "src", directory.to_s)
    FileUtils.mkdir_p(collections_dir)

    FileUtils.cp_r Paths.source_dir.join("test", "source", "src", "_methods"), collections_dir
    FileUtils.cp_r Paths.source_dir.join("test", "source", "src", "_thanksgiving"), collections_dir
    FileUtils.cp_r Paths.source_dir.join("test", "source", "src", "_tutorials"), collections_dir
  end
end
