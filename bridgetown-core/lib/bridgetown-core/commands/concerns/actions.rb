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

      def transform_automation_url(arg)
        remote_file = if arg.end_with?(".rb")
                        arg.split("/").yield_self do |segments|
                          arg.sub!(%r!/#{segments.last}$!, "")
                          segments.last
                        end
                      else
                        "bridgetown.automation.rb"
                      end

        if arg.start_with?("https://gist.github.com")
          return arg.sub(
            "https://gist.github.com", "https://gist.githubusercontent.com"
          ) + "/raw/#{remote_file}"
        elsif arg.start_with?("https://github.com")
          return arg.sub(
            "https://github.com", "https://raw.githubusercontent.com"
          ) + "/master/#{remote_file}"
        end

        # TODO: option to download and confirm remote automation?

        arg
      end
    end
  end
end
