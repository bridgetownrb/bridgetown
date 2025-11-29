# frozen_string_literal: true

module Bridgetown
  module Commands
    # Automation tasks to aid in setting up new Bridgetown site configs or plugin setup.
    # Also includes all of the tasks provided by Freyia
    module Automations
      include Freyia::Setup

      def self.included(klass)
        klass.extend Freyia::Setup::ClassMethods
      end

      using Bridgetown::Refinements

      GITHUB_REGEX = %r!https://github\.com!
      GITHUB_TREE_REGEX = %r!#{GITHUB_REGEX}/.*/.*/tree/.*/?!
      GITHUB_BLOB_REGEX = %r!#{GITHUB_REGEX}/.*/.*/blob/!
      GITHUB_REPO_REGEX = %r!github\.com/(.*?/[^/]*)!
      GITLAB_REGEX = %r!https://gitlab\.com!
      GITLAB_TREE_REGEX = %r!#{GITLAB_REGEX}/.*/.*/-/tree/.*/?!
      GITLAB_BLOB_REGEX = %r!#{GITLAB_REGEX}/.*/.*/-/blob/!
      GITLAB_REPO_REGEX = %r!gitlab\.com/(.*?/[^/]*)!
      CODEBERG_REGEX = %r!https://codeberg\.org!
      CODEBERG_TREE_REGEX = %r!#{CODEBERG_REGEX}/.*/.*/src/branch/.*/?!
      CODEBERG_REPO_REGEX = %r!codeberg\.org/(.*?/[^/]*)!

      # Creates a new Builder class with the provided filename and Ruby code
      #
      # @param filename [String]
      # @param data [String] Ruby code, if block not provided
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

      # Adds a new JavaScript import statement to the end of existing import statements (if any)
      #
      # @param data [String] Ruby code, if block not provided
      # @param filename [String] supply a filename if the default `index.js` isn't desired
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

      # Uses `bundle add` to add a new gem to the project `Gemfile`
      #
      # @param gemname [String]
      # @param group [String] normally the gem isn't added to any group, but you can specify
      # a particular group
      # @param version [String] useful if you need to force a specific version or range
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

      # Add an `init` statement to the project's `config/initializers.rb` file
      #
      # @param name [Symbol] initializer / plugin name
      # @param data [String] additional Ruby code, if block not provided
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

      # Similar to the `add_initializer` method, but supports adding arbitrary Ruby code of any
      # kind to the `config/initializers.rb` file
      #
      # @param name [Symbol, String] name of configuration (purely for user display feedback)
      # @param data [String] Ruby code, if block not provided
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

      # Given the name of a gem, it will analyze that gem's metadata looking for a suitable NPM
      # companion package. (Requires `npm_add` to be defined.)
      #
      # @param gemname [Symbol]
      def add_npm_for_gem(gemname)
        say_status :add_npm, gemname

        Bundler.reset!
        Bridgetown::PluginManager.load_determined_bundler_environment
        Bridgetown::PluginManager.install_npm_dependencies(name: gemname)
      rescue SystemExit
        say_status :add_npm, "Package not added due to NPM error", :red
      end
      alias_method :add_yarn_for_gem, :add_npm_for_gem

      # Adds the provided NPM package to the project's `package.json`
      #
      # @param package_details [String] the package name, and any optional flags
      def add_npm_package(package_details)
        run "#{Bridgetown::PluginManager.package_manager} #{Bridgetown::PluginManager.package_manager_install_command} #{package_details}" # rubocop:disable Layout
      end

      # Removes an NPM package
      #
      # @param package_details [String] the package name, and any optional flags
      def remove_npm_package(package_details)
        run "#{Bridgetown::PluginManager.package_manager} #{Bridgetown::PluginManager.package_manager_uninstall_command} #{package_details}" # rubocop:disable Layout
      end

      # Calls Freyia's `apply` method after transforming the URL according to Automations rules
      #
      # @param url [String] URL to a file or a repo
      def apply_from_url(url)
        apply transform_automation_url(url.dup)
      end

      private

      def determine_remote_filename(arg)
        arg.sub!(%r!\?.*$!, "") # chop query string if need be
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
      # @param arg [String]
      def transform_automation_url(arg)
        return arg unless arg.start_with?("http")

        remote_file = determine_remote_filename(arg)

        arg = case arg
              when GITHUB_REGEX
                transform_github_url arg
              when %r{^https://gist.github.com}
                arg.sub( # rubocop:disable Style/StringConcatenation
                  "https://gist.github.com", "https://gist.githubusercontent.com"
                ) + "/raw"
              when GITLAB_REGEX
                transform_gitlab_url arg
              when CODEBERG_REGEX
                transform_codeberg_url arg
              else
                arg
              end

        "#{arg}/#{remote_file}"
      end

      def transform_github_url(url)
        new_url = url.sub(GITHUB_REGEX, "https://raw.githubusercontent.com")
        tree_match = GITHUB_TREE_REGEX.match?(url)
        blob_match = GITHUB_BLOB_REGEX.match?(url)

        if tree_match
          new_url.sub("/tree/", "/")
        elsif blob_match
          new_url.sub("/blob/", "/")
        else
          "#{new_url}/#{Bridgetown::Utils.default_github_branch_name(url)}"
        end
      end

      def transform_gitlab_url(url)
        new_url = url.dup
        tree_match = GITLAB_TREE_REGEX.match?(url)
        blob_match = GITLAB_BLOB_REGEX.match?(url)

        if tree_match
          new_url.sub("/tree/", "/raw/")
        elsif blob_match
          new_url.sub("/blob/", "/raw/")
        else
          "#{new_url}/-/raw/#{Bridgetown::Utils.default_gitlab_branch_name(url)}"
        end
      end

      def transform_codeberg_url(url)
        new_url = url.dup
        tree_match = CODEBERG_TREE_REGEX.match?(url)

        if tree_match
          new_url.sub("/src/", "/raw/")
        else
          "#{new_url}/raw/branch/#{Bridgetown::Utils.default_codeberg_branch_name(url)}"
        end
      end
    end

    Actions = Automations # alias
  end
end
