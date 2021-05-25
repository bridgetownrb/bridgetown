# frozen_string_literal: true

require "helper"

class TestNewCommand < BridgetownUnitTest
  def argumentize(str)
    str.split(" ")
  end

  def dir_contents(path)
    Dir["#{path}/**/*"].each do |file|
      file.gsub! path, ""
    end
  end

  def site_template
    File.expand_path("../lib/site_template", __dir__)
  end

  def site_template_source
    File.expand_path("../lib/site_template/src", __dir__)
  end

  def template_config_files
    ["/Gemfile", "/package.json", "/frontend/javascript/index.js", "/webpack.config.js", "/config/webpack.defaults.js"]
  end

  def static_template_files
    dir_contents(site_template).reject do |f|
      File.extname(f) =~ %r!\.erb|\.(s[ac]|c)ss!
    end
  end

  context "when args contains a path" do
    setup do
      @path = "new-site"
      @args = "new #{@path}"
      @full_path = File.expand_path(@path, Dir.pwd)
      @full_path_source = File.expand_path("src", @full_path)
    end

    teardown do
      FileUtils.rm_r @full_path if File.directory?(@full_path)
    end

    should "create a new folder with Gemfile and package.json" do
      gemfile = File.join(@full_path, "Gemfile")
      packagejson = File.join(@full_path, "package.json")
      refute_exist @full_path
      capture_output do
        Bridgetown::Commands::Base.start(argumentize(@args))
      end
      assert_exist gemfile
      assert_exist packagejson
      assert_match(%r!gem "bridgetown", "~> #{Bridgetown::VERSION}"!, File.read(gemfile))
      assert_match(%r!"start": "node start.js"!, File.read(packagejson))
    end

    should "copy the static files for postcss configuration in site template to the new directory" do
      postcss_config_files = ["/postcss.config.js", "/frontend/styles/index.css"]
      postcss_template_files = static_template_files + postcss_config_files + template_config_files

      capture_output do
        Bridgetown::Commands::Base.start(argumentize("#{@args} --use-postcss"))
      end

      new_site_files = dir_contents(@full_path).reject do |f|
        f.end_with?("welcome-to-bridgetown.md")
      end

      assert_same_elements postcss_template_files, new_site_files
    end

    should "copy the static files for sass configuration in site template to the new directory" do
      sass_config_files = ["/frontend/styles/index.scss"]
      sass_template_files = static_template_files + sass_config_files + template_config_files

      capture_output do
        Bridgetown::Commands::Base.start(argumentize(@args))
      end

      new_site_files = dir_contents(@full_path).reject do |f|
        f.end_with?("welcome-to-bridgetown.md")
      end

      assert_same_elements sass_template_files, new_site_files
    end

    should "process any ERB files" do
      erb_template_files = dir_contents(site_template_source).select do |f|
        File.extname(f) == ".erb"
      end

      stubbed_date = "2013-01-01"
      allow_any_instance_of(Time).to receive(:strftime) { stubbed_date }

      erb_template_files.each do |f|
        f.chomp! ".erb"
        f.gsub! "0000-00-00", stubbed_date
      end

      capture_output do
        Bridgetown::Commands::Base.start(argumentize(@args))
      end

      new_site_files = dir_contents(@full_path_source).select do |f|
        erb_template_files.include? f
      end

      assert_same_elements erb_template_files, new_site_files
    end

    should "force created folder" do
      capture_output { Bridgetown::Commands::Base.start(argumentize(@args)) }

      output = capture_output do
        Bridgetown::Commands::Base.start(argumentize("#{@args} --force"))
      end

      refute_match %r!try again with `--force` to proceed and overwrite any files.!, output
      assert_match %r!identical!, output
    end

    should "skip bundle install when opted to" do
      capture_output do
        Bridgetown::Commands::Base.start(argumentize("#{@args} --skip-bundle"))
      end

      refute_exist File.join(@full_path, "Gemfile.lock")
    end
  end

  context "when multiple args are given" do
    setup do
      @site_name_with_spaces = "new site name"
    end

    teardown do
      FileUtils.rm_r File.expand_path(@site_name_with_spaces, Dir.pwd)
    end

    should "create a new directory" do
      refute_exist @site_name_with_spaces
      invocation = argumentize("new #{@site_name_with_spaces}")
      capture_output { Bridgetown::Commands::Base.start(invocation) }
      assert_exist @site_name_with_spaces
    end
  end

  context "when no args are given" do
    setup do
      @empty_args = []
    end

    should "raise an ArgumentError" do
      exception = assert_raises ArgumentError do
        Bridgetown::Commands::Base.start(["new"])
      end
      assert_equal "You must specify a path.", exception.message
    end
  end
end
