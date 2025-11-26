# frozen_string_literal: true

require "helper"

class TestLayoutReader < BridgetownUnitTest
  describe "reading layouts" do
    before do
      @site = fixture_site
    end

    it "reads layouts" do
      layouts = LayoutReader.new(@site).read
      assert_equal ["default",
                    "erblayout",
                    "rubylayout",
                    "serblayout",
                    "example/overridden_layout",
                    "example/test_layout",
                    "simple",
                    "post/simple",].sort,
                   layouts.keys.sort
    end

    describe "when no _layouts directory exists in CWD" do
      it "knows to use the layout directory relative to the site source" do
        assert_equal LayoutReader.new(@site).layout_directory, source_dir("_layouts")
      end
    end

    describe "when a _layouts directory exists in CWD" do
      it "ignores the layout directory in CWD and uses the directory relative to site source" do
        refute_equal source_dir("blah/_layouts"), LayoutReader.new(@site).layout_directory
        assert_equal source_dir("_layouts"), LayoutReader.new(@site).layout_directory
      end
    end
  end
end
