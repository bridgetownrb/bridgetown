# frozen_string_literal: true

require "helper"

module Bridgetown
  class OutputBufferTest < BridgetownUnitTest
    def setup
      super
      @buffer = Bridgetown::OutputBuffer.new
    end

    should "be able to be duped" do
      @buffer << "Hello"
      copy = @buffer.dup
      copy << " world!"

      assert_equal "Hello", @buffer.to_s
      assert_equal "Hello world!", copy.to_s
    end

    context "#<<" do
      should "maintain HTML safety" do
        @buffer << "<p>Nothing bad to see here.</p>"

        assert_predicate @buffer, :html_safe?
        assert_predicate @buffer.to_s, :html_safe?
        assert_equal "&lt;p&gt;Nothing bad to see here.&lt;/p&gt;", @buffer.to_s
      end
    end

    context "#safe_append=" do
      should "bypass HTML safety" do
        @buffer.safe_append = "<p>Nothing bad to see here.</p>"

        assert_predicate @buffer, :html_safe?
        assert_predicate @buffer.to_s, :html_safe?
        assert_equal "<p>Nothing bad to see here.</p>", @buffer.to_s
      end
    end
  end
end
