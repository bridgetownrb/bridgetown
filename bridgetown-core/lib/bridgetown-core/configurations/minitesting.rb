# frozen_string_literal: true

# rubocop:disable all

say_status :minitesting, "Adding test gems and examples"

append_to_file "Gemfile" do
  <<~GEMS
    \n
    group :test, optional: true do
      gem "nokogiri"
      gem "minitest"
      gem "minitest-profile"
      gem "minitest-reporters"
      gem "shoulda"
      gem "rails-dom-testing"
    end
  GEMS
end

create_file "test/helper.rb" do
  <<~RUBY
    require "nokogiri"
    require "minitest/autorun"
    require "minitest/reporters"
    require "minitest/profile"
    require "shoulda"
    require "rails-dom-testing"

    # Report with color.
    Minitest::Reporters.use! [
      Minitest::Reporters::DefaultReporter.new(
        color: true
      ),
    ]

    Minitest::Test.class_eval do
      include Rails::Dom::Testing::Assertions

      def site
        @site ||= Bridgetown::Current.site
      end

      def nokogiri(input)
        input.respond_to?(:output) ? Nokogiri::HTML(input.output) : Nokogiri::HTML(input)
      end

      def document_root(root)
        @document_root = root.is_a?(Nokogiri::XML::Document) ? root : nokogiri(root)
      end

      def document_root_element
        if @document_root.nil?
          raise "Call `document_root' with a Nokogiri document before testing your assertions"
        end
        @document_root
      end
    end
  RUBY
end

create_file "test/test_homepage.rb" do
  <<~RUBY
    require_relative "./helper"

    class TestHomepage < Minitest::Test
      context "homepage" do
        setup do
          page = site.collections.pages.resources.find { |doc| doc.relative_url == "/" }
          document_root page
        end

        should "exist" do
          assert_select "body"
        end
      end
    end
  RUBY
end

create_file "plugins/test_output.rb" do
  <<~RUBY
    module TestOutput
      unless Bridgetown.env.development?
        Bridgetown::Hooks.register_one :site, :post_write do
          # Load test suite to run on exit
          require "nokogiri"
          Dir["test/**/*.rb"].each { |file| require_relative("../\#{file}") }
        rescue LoadError
          Bridgetown.logger.warn "Testing:", "To run tests, you must first run \`bundle install --with test\`"
        end
      end
    end
  RUBY
end

say_status :minitesting, "All set! To get started, look at test/test_homepage.rb and then run \`bin/bridgetown test\`"

# rubocop:enable all