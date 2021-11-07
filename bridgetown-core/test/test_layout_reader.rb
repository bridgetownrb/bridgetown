# frozen_string_literal: true

require "helper"

class TestLayoutReader < BridgetownUnitTest
  context "reading layouts" do
    setup do
      @site = fixture_site
    end

    should "read layouts" do
      layouts = LayoutReader.new(@site).read
      assert_equal ["default",
                    "erblayout",
                    "serblayout",
                    "example/overridden_layout",
                    "example/test_layout",
                    "simple",
                    "post/simple",].sort,
                   layouts.keys.sort
    end

    context "when no _layouts directory exists in CWD" do
      should "know to use the layout directory relative to the site source" do
        assert_equal LayoutReader.new(@site).layout_directory, source_dir("_layouts")
      end
    end

    context "when a _layouts directory exists in CWD" do
      setup do
        allow(File).to receive(:directory?).and_return(true)
        allow(Dir).to receive(:pwd).and_return(source_dir("blah"))
      end

      should "ignore the layout directory in CWD and use the directory relative to site source" do
        refute_equal source_dir("blah/_layouts"), LayoutReader.new(@site).layout_directory
        assert_equal source_dir("_layouts"), LayoutReader.new(@site).layout_directory
      end
    end
  end
end
