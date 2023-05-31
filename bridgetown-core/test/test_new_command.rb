# frozen_string_literal: true

require "helper"

class TestNewCommand < BridgetownUnitTest
  def argumentize(str)
    str.split
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
    [
      "/Gemfile",
      "/Rakefile",
      "/package.json",
      "/frontend/javascript/index.js",
      "/frontend/styles/syntax-highlighting.css",
      "/src/_layouts",
      "/src/_components",
      "/src/index.md",
      "/src/posts.md",
    ]
  end

  def liquid_config_files
    [
      "/src/_layouts/page.liquid",
      "/src/_layouts/post.liquid",
      "/src/_layouts/default.liquid",
      "/src/_components/navbar.liquid",
      "/src/_components/head.liquid",
      "/src/_components/footer.liquid",
    ]
  end

  def erb_config_files
    [
      "/src/_layouts/page.erb",
      "/src/_layouts/post.erb",
      "/src/_layouts/default.erb",
      "/src/_components/shared",
      "/src/_components/shared/navbar.rb",
      "/src/_components/shared/navbar.erb",
      "/src/_partials",
      "/src/_partials/_head.erb",
      "/src/_partials/_footer.erb",
    ]
  end

  def esbuild_config_files
    ["/esbuild.config.js", "/jsconfig.json", "/config/esbuild.defaults.js"]
  end

  def webpack_config_files
    ["/webpack.config.js", "/config/webpack.defaults.js"]
  end

  def static_template_files
    dir_contents(site_template).reject do |f|
      f.include?("TEMPLATE") || File.extname(f) =~ %r!\.erb|\.(s[ac]|c)ss!
    end
  end

  context "when args contains a path" do
    setup do
      @path = SecureRandom.alphanumeric
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
      assert_match(%r!gem "bridgetown", "~> #{Bridgetown::VERSION}"!o, File.read(gemfile))
      assert_match(%r!"esbuild":!, File.read(packagejson))
    end

    should "display a success message" do
      output = capture_output do
        Bridgetown::Commands::Base.start(argumentize(@args))
      end
      success_message = "Your new Bridgetown site was generated in " \
                        "#{@path.cyan}."

      assert_includes output, success_message
    end

    should "copy the static files for postcss configuration in site template to the new directory" do
      postcss_config_files = ["/postcss.config.js", "/frontend/styles/index.css"]
      postcss_template_files = static_template_files + postcss_config_files + template_config_files + liquid_config_files + esbuild_config_files

      capture_output do
        Bridgetown::Commands::Base.start(argumentize(@args))
      end

      new_site_files = dir_contents(@full_path).reject do |f|
        f.end_with?("welcome-to-bridgetown.md")
      end

      assert_same_elements postcss_template_files, new_site_files
    end

    should "copy the static files for erb templates config to the new directory" do
      postcss_config_files = ["/postcss.config.js", "/frontend/styles/index.css"]
      postcss_template_files = static_template_files + postcss_config_files + template_config_files + erb_config_files + esbuild_config_files

      capture_output do
        Bridgetown::Commands::Base.start(argumentize("#{@args} -t erb"))
      end

      new_site_files = dir_contents(@full_path).reject do |f|
        f.end_with?("welcome-to-bridgetown.md")
      end

      assert_same_elements postcss_template_files, new_site_files
    end

    should "copy the static files for sass configuration in site template to the new directory" do
      sass_config_files = ["/frontend/styles/index.scss"]
      sass_template_files = static_template_files + sass_config_files + template_config_files + liquid_config_files + webpack_config_files

      capture_output do
        Bridgetown::Commands::Base.start(argumentize("#{@args} -e webpack --use-sass"))
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
      assert_match %r!new Bridgetown site was generated in!, output
    end

    should "skip bundle install when opted to" do
      output = capture_output do
        Bridgetown::Commands::Base.start(argumentize("#{@args} --skip-bundle"))
      end

      refute_exist File.join(@full_path, "Gemfile.lock")
      bundle_message = "Bundle install skipped."
      assert_includes output, bundle_message
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

    should "display an error message" do
      output = capture_output do
        Bridgetown::Commands::Base.start(["new"])
      end

      assert_includes output, "You must specify a path."
    end
  end
end
