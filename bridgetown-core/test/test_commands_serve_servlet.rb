# frozen_string_literal: true

require "webrick"
require "helper"

class TestCommandsServeServlet < BridgetownUnitTest
  def get(path)
    TestWEBrick.mount_server do |_server, addr, port|
      yield Faraday.get("http://#{addr}:#{port}#{path}")
    end
  end

  context "with a directory and file with the same name" do
    should "find that file" do
      get("/bar/") do |response|
        assert_equal(200, response.status)
        assert_equal("Content of bar.html", response.body.strip)
      end
    end

    should "find file in directory" do
      get("/bar/baz") do |response|
        assert_equal(200, response.status)
        assert_equal("Content of baz.html", response.body.strip)
      end
    end

    should "return 404 for non-existing files" do
      get("/bar/missing") do |response|
        assert_equal(404, response.status)
      end
    end

    should "find xhtml file" do
      get("/bar/foo") do |response|
        assert_equal(200, response.status)
        assert_equal(
          '<html xmlns="http://www.w3.org/1999/xhtml">Content of foo.xhtml</html>',
          response.body.strip
        )
      end
    end
  end
end
