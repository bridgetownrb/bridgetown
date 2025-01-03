# frozen_string_literal: true

module Bridgetown
  # This is for including into Minitest::Expectation
  module IntuitiveExpectations
    def true?(msg = nil)
      must_be(:itself, Minitest::Assertions::UNDEFINED, msg)
      self
    end

    def false?(msg = nil)
      wont_be(:itself, Minitest::Assertions::UNDEFINED, msg)
      self
    end

    def ==(other)
      must_equal(other)
      self
    end

    def !=(other)
      must_not_equal(other)
      self
    end

    def nil?(msg = nil)
      must_be_nil(msg)
      self
    end

    def not_nil?(msg = nil)
      wont_be_nil(msg)
      self
    end

    def empty?(msg = nil)
      must_be_empty(msg)
      self
    end

    def filled?(msg = nil)
      wont_be_empty(msg)
      self
    end

    def include?(other, msg = nil)
      must_include(other, msg)
      self
    end
    alias_method :<<, :include?

    def exclude?(other, msg = nil)
      wont_include(other, msg)
      self
    end

    def =~(other)
      must_match(other)
      self
    end

    def is_a?(klass, msg = nil)
      must_be_instance_of(klass, msg)
      self
    end
  end
end
