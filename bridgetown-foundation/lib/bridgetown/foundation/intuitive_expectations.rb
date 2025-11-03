# frozen_string_literal: true

require "bridgetown/foundation/refine_ext/object"

module Bridgetown::Foundation
  # This module provides a set of Ruby syntax-inspired mechanism for writing expectations
  # which wrap the native statements within `Minitest::Expectation`.
  #
  # Generally the methods here return self, so you can chain multiple expectations together
  # for a single object.
  module IntuitiveExpectations
    using Bridgetown::Foundation::RefineExt::Object

    # Use this in your main test helper to enrich `Minitest::Expectation`, or something akin to it
    #
    # @param [Module(Minitest)]
    def self.enrich(mod)
      mod::Expectation.include self
      filter_exp = %r!bridgetown/foundation/intuitive_expectations\.rb!
      if mod.backtrace_filter.respond_to?(:add_filter)
        mod.backtrace_filter.add_filter filter_exp
      else
        mod.backtrace_filter = mod::BacktraceFilter.new(%r!#{mod::BacktraceFilter::MT_RE}|#{filter_exp}!)
      end
    end

    # Expect the object to be a truthy value
    # @return [Minitest::Expectation]
    def truthy?(msg = nil)
      ctx.assert target, msg
      self
    end
    alias_method :true?, :truthy?

    # Expect the object to be a falsy value
    # @return [Minitest::Expectation]
    def falsy?(msg = nil)
      ctx.refute target, msg
      self
    end
    alias_method :falsey?, :falsy?
    alias_method :false?, :falsy?

    # Expect the object to return a truthy value from a predicate, e.g.
    # `expect(new_user).is? :new?`
    # @return [Minitest::Expectation]
    def is?(sym, msg = nil)
      must_be(sym, Minitest::Assertions::UNDEFINED, msg)
      self
    end

    # Expect the object to return a falsy value from a predicate, e.g.
    # `expect(saved_user).isnt? :new?`
    # @return [Minitest::Expectation]
    def isnt?(sym, msg = nil)
      wont_be(sym, Minitest::Assertions::UNDEFINED, msg)
      self
    end

    # Expect the object to equal a value
    # @return [Minitest::Expectation]
    def equal?(other, msg = nil)
      must_equal(other, msg)
      self
    end
    alias_method :==, :equal?

    # Expect the object not to equal a value
    # @return [Minitest::Expectation]
    def not_equal?(other, msg = nil)
      wont_equal(other, msg)
      self
    end
    alias_method :!=, :not_equal?

    # Expect the object to be within another value (as defined by the `within?`
    # object refinement)
    # @return [Minitest::Expectation]
    def within?(other, msg = nil)
      msg = ctx.message(msg) { "Expected #{ctx.mu_pp target} to be within #{ctx.mu_pp other}" }
      ctx.assert target.within?(other), msg
      self
    end

    # Expect the object not to be within another value (as defined by the `within?`
    # object refinement)
    # @return [Minitest::Expectation]
    def not_within?(other, msg = nil)
      msg = ctx.message(msg) { "Expected #{ctx.mu_pp target} to not be within #{ctx.mu_pp other}" }
      ctx.refute target.within?(other), msg
      self
    end

    # Expect the object to be nil
    # @return [Minitest::Expectation]
    def nil?(msg = nil)
      must_be_nil(msg)
      self
    end

    # Expect the object not to be nil
    # @return [Minitest::Expectation]
    def not_nil?(msg = nil)
      wont_be_nil(msg)
      self
    end

    # Expect the object (like a string, array, etc.) to be empty
    # @return [Minitest::Expectation]
    def empty?(msg = nil)
      must_be_empty(msg)
      self
    end

    # Expect the object (like a string, array, etc.) not to be empty
    # @return [Minitest::Expectation]
    def not_empty?(msg = nil)
      wont_be_empty(msg)
      self
    end
    alias_method :filled?, :not_empty?

    # Expect the object (like a string, array, etc.) to include another value
    # @return [Minitest::Expectation]
    def include?(other, msg = nil)
      must_include(other, msg)
      self
    end
    alias_method :<<, :include?

    # Expect the object (like a string, array, etc.) not to include another value
    # @return [Minitest::Expectation]
    def exclude?(other, msg = nil)
      wont_include(other, msg)
      self
    end
    alias_method :not_include?, :exclude?

    # Expect the object to match a regular expression
    # @return [Minitest::Expectation]
    def match?(other, msg = nil)
      must_match(other, msg)
      self
    end
    alias_method :=~, :match?

    # Expect the object not to match a regular expression
    # @return [Minitest::Expectation]
    def not_match?(other, msg = nil)
      wont_match(other, msg)
      self
    end

    # Expect the object to be an instance of a class (or a subclass)
    # @return [Minitest::Expectation]
    def is_a?(klass, msg = nil)
      must_be_kind_of(klass, msg)
      self
    end
    alias_method :kind_of?, :is_a?

    # Expect the object not to be an instance of a class (or a subclass)
    # @return [Minitest::Expectation]
    def not_a?(klass, msg = nil)
      wont_be_kind_of(klass, msg)
      self
    end
    alias_method :isnt_a?, :not_a?
    alias_method :is_not_a?, :not_a?
    alias_method :not_kind_of?, :not_a?

    # Expect the block not to raise the exception
    # @return [Minitest::Expectation]
    def raise?(exception, msg = nil)
      Warning.warn "Calling `#{__callee__}` for the same block re-executes the block" if @block_ran
      @block_ran ||= true
      # we need this ternary operator because `must_raise` takes a variable number of arguments
      msg ? must_raise(exception, msg) : must_raise(exception)
      self
    end

    # Expect the block to send output to stdout and/or stderr
    # @param stdout [String, Regexp]
    # @param stderr [String, Regexp]
    # @return [Minitest::Expectation]
    def output?(stdout = nil, stderr = nil)
      Warning.warn "Calling `#{__callee__}` for the same block re-executes the block" if @block_ran
      @block_ran ||= true
      must_output stdout, stderr
      self
    end

    # Expect the block not to send output to stdout and stderr
    # @return [Minitest::Expectation]
    def not_output?
      Warning.warn "Calling `#{__callee__}` for the same block re-executes the block" if @block_ran
      @block_ran ||= true
      must_be_silent
      self
    end
    alias_method :silent?, :not_output?
  end
end
