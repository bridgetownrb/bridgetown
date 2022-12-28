# frozen_string_literal: true

module Bridgetown
  module Commands
    module Actions
      GITHUB_REGEX = %r!https://github\.com!.freeze
      GITHUB_TREE_REGEX = %r!#{GITHUB_REGEX}/.*/.*/tree/.*/?!.freeze
      GITHUB_BLOB_REGEX = %r!#{GITHUB_REGEX}/.*/.*/blob/!.freeze
      GITHUB_REPO_REGEX = %r!github\.com/(.*?/[^/]*)!.freeze

      def create_builder(filename, data = nil)
        say_status :create_builder, filename
        data ||= yield if block_given?

        site_builder = File.join("plugins", "site_builder.rb")
        unless File.exist?(site_builder)
          create_file("plugins/site_builder.rb", verbose: true) do
            <<~RUBY
              class SiteBuilder < Bridgetown::Builder
              end
            RUBY
          end
        end

        create_file("plugins/builders/#{filename}", data, verbose: false)
      end

      def javascript_import(data = nil, filename: "index.js") # rubocop:todo Metrics/PerceivedComplexity
        data ||= yield if block_given?
        data += "\n" unless data[-1] == "\n"

        say_status :javascript_import, filename

        js_index = File.join("frontend", "javascript", filename)
        if File.exist?(js_index)
          index_file = File.read(js_index)

          last_import = ""
          index_file.each_line do |line|
            line.start_with?("import ") ? last_import = line : break
          end

          if last_import == ""
            # add to top of file
            prepend_file js_index, data, verbose: false
          else
            # inject after the last import line
            inject_into_file js_index, data, after: last_import, verbose: false, force: false
          end
        else
          create_file(js_index, data, verbose: false)
        end
      end

      def add_gem(gemname, group: nil, version: nil)
        options = +""
        options += " -v \"#{version}\"" if version
        options += " -g #{group}" if group
        # in_bundle? returns the path to the gemfile
        run "bundle add #{gemname}#{options}",
            env: { "BUNDLE_GEMFILE" => Bundler::SharedHelpers.in_bundle? }
      rescue SystemExit
        say_status :run, "Gem not added due to bundler error", :red
      end
      alias_method :add_bridgetown_plugin, :add_gem

      def add_initializer(name, data = "")
        say_status :initializer, name
        data = yield if block_given?
        data = data.indent(2).lstrip
        data = " #{data}" unless data.start_with?(",")
        data += "\n" unless data[-1] == "\n"

        init_file = File.join("config", "initializers.rb")
        unless File.exist?(init_file)
          create_file("config/initializers.rb", verbose: true) do
            File.read(File.expand_path("../../../site_template/config/initializers.rb", __dir__))
          end
        end

        inject_into_file init_file, %(  init :"#{name}"#{data}),
                         before: %r!^end$!, verbose: false, force: false
      end

      def ruby_configure(name, data = "")
        say_status :configure, name
        data = yield if block_given?
        data = data.indent(2)
        data += "\n" unless data[-1] == "\n"

        init_file = File.join("config", "initializers.rb")
        unless File.exist?(init_file)
          create_file("config/initializers.rb", verbose: true) do
            File.read(File.expand_path("../../../site_template/config/initializers.rb", __dir__))
          end
        end

        inject_into_file init_file, data,
                         before: %r!^end$!, verbose: false, force: false
      end

      def add_yarn_for_gem(gemname)
        say_status :add_yarn, gemname

        Bundler.reset!
        Bridgetown::PluginManager.load_determined_bundler_environment
        Bridgetown::PluginManager.install_yarn_dependencies(name: gemname)
      rescue SystemExit
        say_status :add_yarn, "Package not added due to yarn error", :red
      end

      def apply_from_url(url)
        apply transform_automation_url(url.dup)
      end

      private

      def determine_remote_filename(arg)
        if arg.end_with?(".rb")
          arg.split("/").then do |segments|
            arg.sub!(%r!/#{segments.last}$!, "")
            segments.last
          end
        else
          "bridgetown.automation.rb"
        end
      end

      # TODO: option to download and confirm remote automation?
      # rubocop:disable Metrics/MethodLength
      def transform_automation_url(arg)
        return arg unless arg.start_with?("http")

        remote_file = determine_remote_filename(arg)
        github_match = GITHUB_REGEX.match(arg)

        arg = if arg.start_with?("https://gist.github.com")
                arg.sub( # rubocop:disable Style/StringConcatenation
                  "https://gist.github.com", "https://gist.githubusercontent.com"
                ) + "/raw"
              elsif github_match
                new_url = arg.sub(GITHUB_REGEX, "https://raw.githubusercontent.com")
                github_tree_match = GITHUB_TREE_REGEX.match(arg)
                github_blob_match = GITHUB_BLOB_REGEX.match(arg)

                if github_tree_match
                  new_url.sub("/tree/", "/")
                elsif github_blob_match
                  new_url.sub("/blob/", "/")
                else
                  "#{new_url}/#{Bridgetown::Utils.default_github_branch_name(arg)}"
                end
              else
                arg
              end

        "#{arg}/#{remote_file}"
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
