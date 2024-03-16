# frozen_string_literal: true

require "helper"

module Bridgetown
  module FrontMatter
    module Loaders
      class TestRuby < BridgetownUnitTest
        context "The `FrontMatter::Loaders::Ruby.header?` method" do
          should "accept files with Ruby front matter" do
            file = source_dir("_posts", "2023-06-30-ruby-front-matter.md")

            assert_equal "```ruby", File.open(file, "rb") { |f| f.read(7) }
            assert Ruby.header?(file)
          end
        end
      end
    end
  end
end
