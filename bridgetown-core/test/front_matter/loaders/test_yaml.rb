# frozen_string_literal: true

require "helper"

module Bridgetown
  module FrontMatter
    module Loaders
      class TestYaml < BridgetownUnitTest
        context "The `FrontMatter::Loaders::YAML.header?` method" do
          should "accept files with YAML front matter" do
            file = source_dir("_posts", "2008-10-18-foo-bar.markdown")

            assert_equal "---\n", File.open(file, "rb") { |f| f.read(4) }
            assert YAML.header?(file)
          end

          should "accept files with extraneous spaces after YAML front matter" do
            file = source_dir("_posts", "2015-12-27-extra-spaces.markdown")

            assert_equal "---  \n", File.open(file, "rb") { |f| f.read(6) }
            assert YAML.header?(file)
          end

          should "reject pgp files and the like which resemble front matter" do
            file = source_dir("pgp.key")

            assert_equal "-----B", File.open(file, "rb") { |f| f.read(6) }
            refute YAML.header?(file)
          end
        end
      end
    end
  end
end
