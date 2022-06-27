# frozen_string_literal: true

require "helper"

class TestModel < BridgetownUnitTest
  context "Models" do
    setup do
      # @type [Bridgetown::Site]
      @site = resources_site
      @origin = Bridgetown::Model::RepoOrigin.new_with_collection_path(:pages, "_pages/_test_file.md")
      @filepath = @site.in_source_dir("_pages/_test_file.md")
    end

    should "save and load content" do
      model = Bridgetown::Model::Base.new(title: "Hello", layout: :page)
      model.content = "Super **great** content!"
      model.origin = @origin
      model.save

      new_model = Bridgetown::Model::Base.new(@origin.read)

      assert_equal model.title, new_model.title
      assert_equal model.layout, new_model.layout.to_sym
      assert_equal model.content, new_model.content
    ensure
      FileUtils.rm_rf(@filepath)
    end

    should "refrain from overwriting non-YAML front matter files" do
      model = Bridgetown::Model::Base.new(title: "Hello", layout: :page)
      model.content = "Super **great** content!"
      model.origin = @origin

      File.write(@filepath, "~~~ruby")

      assert_raises Bridgetown::Errors::FatalException do
        model.save
      end

      File.write(@filepath, "---\n")
      model.save

      assert_includes File.read(@filepath), "---\ntitle: Hello"
    ensure
      FileUtils.rm_rf(@filepath)
    end
  end
end
