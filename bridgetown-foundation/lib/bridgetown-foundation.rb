# frozen_string_literal: true

require "bridgetown/version"
require "hash_with_dot_access"
require "inclusive"
require "zeitwerk"
require "delegate"

module Bridgetown::Foundation
  # This is loosly based on the `deprecate` method in `Gem::Deprecate`
  #
  # @param target [Object]
  # @param name [Symbol] e.g. `:howdy`
  # @param repl [Symbol] e.g. `:hello`
  # @param year [Integer] e.g. `2025`
  # @param month [Integer] e.g. `1` for January
  def self.deprecation_warning(target, name, repl, year, month) # rubocop:disable Metrics/ParameterLists
    klass = target.is_a?(Module)
    target = klass ? "#{self}." : "#{self.class}#"
    msg = [
      "NOTE: #{target}#{name} is deprecated",
      repl == :none ? " with no replacement" : "; use #{repl} instead",
      format(". It will be removed on or after %4d-%02d.", year, month), # rubocop:disable Style/FormatStringToken
      "\n#{target}#{name} called from #{Gem.location_of_caller.join(":")}",
    ]
    warn "#{msg.join}."
  end
end

# You can add `using Bridgetown::Refinements` to any portion of your Ruby code to load in all
# of the refinements available in Foundation. Or you can add a using statement for a particular
# refinement which lives inside `Bridgetown::Foundation::RefineExt`.
module Bridgetown::Refinements
  include HashWithDotAccess::Refinements
end

Zeitwerk.with_loader do |l|
  l.push_dir "#{__dir__}/bridgetown/foundation", namespace: Bridgetown::Foundation
  l.ignore "#{__dir__}/bridgetown/foundation/version.rb"
  l.setup
  l.eager_load
end

module Bridgetown
  # Any method call sent will be passed along to the wrapped object with refinements activated
  class WrappedObjectWithRefinements < SimpleDelegator
    using Bridgetown::Refinements

    # rubocop:disable Style/MissingRespondToMissing
    def method_missing(method, ...) = __getobj__.send(method, ...)
    # rubocop:enable Style/MissingRespondToMissing
  end

  # Call this method to wrap any object(s) in order to use Foundation's refinements
  #
  # @param *obj [Object]
  # @return [WrappedObjectWithRefinements]
  def self.refine(*obj)
    if obj.length == 1
      WrappedObjectWithRefinements.new(obj[0])
    else
      obj.map { WrappedObjectWithRefinements.new _1 }
    end
  end

  def self.add_refinement(mod, &)
    Bridgetown::Refinements.include(mod)
    Bridgetown::WrappedObjectWithRefinements.class_eval(&)
  end
end
