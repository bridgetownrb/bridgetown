# frozen_string_literal: true

# rubocop:disable all

say_status :minitesting, "Adding test gems and examples"

append_to_file "Gemfile" do
  <<~GEMS
    \n
    group :test do
      gem "minitest"
      gem "minitest-reporters"
      gem "rack-test"
    end
  GEMS
end

gsub_file "Gemfile", '# gem "nokolexbor"', 'gem "nokolexbor"'

insert_into_file "Rakefile", after: %(ENV["BRIDGETOWN_ENV"] = "test"\n  Bridgetown::Commands::Build.start\nend\n) do
  <<~RUBY

    require "minitest/test_task"
    Minitest::TestTask.create(:test) do |t| # add on to the test task
      t.warning = false
    end
  RUBY
end

create_file "test/minitest_helper.rb" do
  <<~RUBY
    ENV["MT_NO_EXPECTATIONS"] = "true"
    require "minitest/autorun"
    require "minitest/reporters"
    Minitest::Reporters.use! [Minitest::Reporters::ProgressReporter.new]

    require "bridgetown/test"
  RUBY
end

create_file "test/test_homepage.rb" do
  <<~RUBY
    require "minitest_helper"

    class TestHomepage < Bridgetown::Test
      def test_homepage
        html get "/"

        assert document.query_selector("body")
      end
    end
  RUBY
end

run "bundle install", env: { "BUNDLE_GEMFILE" => Bundler::SharedHelpers.in_bundle? }

say_status :minitesting, "All set! To get started, look at test/test_homepage.rb and then run \`bin/bridgetown test\`"

# rubocop:enable all