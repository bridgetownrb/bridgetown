# frozen_string_literal: true

# Mostly not used here, but may come in handy in new automations
require "active_support/core_ext/array/extract_options"
require "active_support/core_ext/string/strip"
require "active_support/core_ext/string/indent"

module Bridgetown
  module Commands
    module Actions
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

      def javascript_import(data = nil, filename: "index.js")
        data ||= yield if block_given?
        data += "\n" unless data.chars.last == "\n"

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

      def add_bridgetown_plugin(gemname, version: nil)
        version = " -v \"#{version}\"" if version
        run "bundle add #{gemname}#{version} -g bridgetown_plugins"
      rescue SystemExit
        say_status :run, "Gem not added due to bundler error", :red
      end

      def add_yarn_for_gem(gemname)
        say_status :add_yarn, gemname

        Bundler.reset!
        available_gems = Bundler.setup Bridgetown::PluginManager::PLUGINS_GROUP
        Bridgetown::PluginManager.install_yarn_dependencies(
          available_gems.requested_specs, gemname
        )
      rescue SystemExit
        say_status :add_yarn, "Package not added due to yarn error", :red
      end

      def apply_from_url(url)
        apply transform_automation_url(url.dup)
      end

      private

      def determine_remote_filename(arg)
        if arg.end_with?(".rb")
          arg.split("/").yield_self do |segments|
            arg.sub!(%r!/#{segments.last}$!, "")
            segments.last
          end
        else
          "bridgetown.automation.rb"
        end
      end


      # TODO: option to download and confirm remote automation?
      def transform_automation_url(arg)
        return arg unless arg.start_with?("http")

        remote_file = determine_remote_filename(arg)

        github_regex = %r!https://github\.com!
        github_tree_regex = %r!#{github_regex}/(?<repo>.*/.*)/tree/(?<path.*)/?!

        github_match = github_regex.match(arg)
        github_tree_match = github_tree_regex.match(arg)

        if arg.start_with?("https://gist.github.com")
          return arg.sub(
            "https://gist.github.com", "https://gist.githubusercontent.com"
          ) + "/raw/#{remote_file}"
        elsif github_match
          new_url = arg.sub(github_regex, "https://raw.githubusercontent.com")

          if github_tree_match
            new_url = new_url.sub("/tree/", "/")
          else
            new_url += "/master"
          end

          return "#{new_url}/#{remote_file}"
        end

        arg + "/#{remote_file}"
      end
    end
  end
end
