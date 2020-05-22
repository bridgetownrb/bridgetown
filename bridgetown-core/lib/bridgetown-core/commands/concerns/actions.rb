# frozen_string_literal: true

# These are additional Thor-style actions provided to automations
# Much of this code is lifted from Rails' custom actions
# https://github.com/rails/rails/blob/master/railties/lib/rails/generators/actions.rb

require "active_support/core_ext/array/extract_options"
require "active_support/core_ext/string/strip"
require "active_support/core_ext/string/indent"

module Bridgetown
  module Commands
    module Actions
      def initialize(*) # :nodoc:
        super
        @indentation = 0
      end

      # Adds an entry into +Gemfile+ for the supplied gem.
      #
      #   gem "rspec", group: :test
      #   gem "technoweenie-restful-authentication", lib: "restful-authentication", source: "http://gems.github.com/"
      #   gem "rails", "3.0", git: "https://github.com/rails/rails"
      #   gem "RedCloth", ">= 4.1.0", "< 4.2.0"
      def gem(*args) # rubocop:todo Metrics/AbcSize
        options = args.extract_options!
        name, *versions = args

        # Set the message to be shown in logs. Uses the git repo if one is given,
        # otherwise use name (version).
        parts = [quote(name)]
        message = name.dup

        # rubocop:todo Lint/AssignmentInCondition
        if versions = versions.any? ? versions : options.delete(:version)
          # rubocop:enable Lint/AssignmentInCondition
          versions_arr = Array(versions)
          versions_arr.each do |version|
            parts << quote(version)
          end
          message << " (#{versions_arr.join(", ")})"
        end
        message = options[:git] if options[:git]

        log :gemfile, message

        parts << quote(options) unless options.empty?

        in_root do
          str = "gem #{parts.join(", ")}"
          str = indentation + str
          append_file_with_newline "Gemfile", str, verbose: false
        end
      end

      # Wraps gem entries inside a group.
      #
      #   gem_group :development, :test do
      #     gem "rspec-rails"
      #   end
      def gem_group(*names, &block)
        options = names.extract_options!
        str = names.map(&:inspect)
        str << quote(options) unless options.empty?
        str = str.join(", ")
        log :gemfile, "group #{str}"

        in_root do
          append_file_with_newline "Gemfile", "\ngroup #{str} do", force: true
          with_indentation(&block)
          append_file_with_newline "Gemfile", "end", force: true
        end
      end

      def github(repo, options = {}, &block)
        str = [quote(repo)]
        str << quote(options) unless options.empty?
        str = str.join(", ")
        log :github, "github #{str}"

        in_root do
          if @indentation.zero?
            append_file_with_newline "Gemfile", "\ngithub #{str} do", force: true
          else
            append_file_with_newline "Gemfile", "#{indentation}github #{str} do", force: true
          end
          with_indentation(&block)
          append_file_with_newline "Gemfile", "#{indentation}end", force: true
        end
      end

      # Add the given source to +Gemfile+
      #
      # If block is given, gem entries in block are wrapped into the source group.
      #
      #   add_source "http://gems.github.com/"
      #
      #   add_source "http://gems.github.com/" do
      #     gem "rspec-rails"
      #   end
      def add_source(source, _options = {}, &block)
        log :source, source

        in_root do
          if block
            append_file_with_newline "Gemfile", "\nsource #{quote(source)} do", force: true
            with_indentation(&block)
            append_file_with_newline "Gemfile", "end", force: true
          else
            prepend_file "Gemfile", "source #{quote(source)}\n", verbose: false
          end
        end
      end

      def create_builder(filename, data = nil)
        log :create_builder, filename
        data ||= yield if block_given?
        create_file("plugins/builders/#{filename}", optimize_indentation(data), verbose: false)
      end

      def javascript_import(data = nil, filename: "index.js")
        data ||= yield if block_given?
        data += "\n" unless data.chars.last == "\n"

        log :javascript_import, filename

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
        log :add_yarn, gemname

        Bundler.reset!
        available_gems = Bundler.setup Bridgetown::PluginManager::PLUGINS_GROUP
        Bridgetown::PluginManager.install_yarn_dependencies(
          available_gems.requested_specs, gemname
        )
      rescue SystemExit
        say_status :add_yarn, "Package not added due to yarn error", :red
      end

      private

      def log(*args)
        if args.size == 1
          say args.first.to_s unless options.quiet?
        else
          args << (behavior == :invoke ? :green : :red)
          say_status(*args)
        end
      end

      # Surround string with single quotes if there is no quotes.
      # Otherwise fall back to double quotes
      def quote(value)
        if value.respond_to? :each_pair
          return value.map do |k, v|
            "#{k}: #{quote(v)}"
          end.join(", ")
        end
        return value.inspect unless value.is_a? String

        if value.include?("'")
          value.inspect
        else
          "'#{value}'"
        end
      end

      # Returns optimized string with indentation
      def optimize_indentation(value, amount = 0)
        return "#{value}\n" unless value.is_a?(String)

        "#{value.strip_heredoc.indent(amount).chomp}\n"
      end

      # Indent the +Gemfile+ to the depth of @indentation
      def indentation
        "  " * @indentation
      end

      # Manage +Gemfile+ indentation for a DSL action block
      def with_indentation(&block)
        @indentation += 1
        instance_eval(&block)
      ensure
        @indentation -= 1
      end

      # Append string to a file with a newline if necessary
      def append_file_with_newline(path, str, options = {})
        gsub_file path, %r!\n?\z!, options do |match|
          match.end_with?("\n") ? "" : "\n#{str}\n"
        end
      end
    end
  end
end
