# frozen_string_literal: true

module Bridgetown
  module Errors
    FatalException = Class.new(::RuntimeError)

    DropMutationException       = Class.new(FatalException)
    InvalidPermalinkError       = Class.new(FatalException)
    InvalidYAMLFrontMatterError = Class.new(FatalException)
    MissingDependencyException  = Class.new(FatalException)

    InvalidDateError            = Class.new(FatalException)
    InvalidPostNameError        = Class.new(FatalException)
    PostURLError                = Class.new(FatalException)
    InvalidURLError             = Class.new(FatalException)
    InvalidConfigurationError   = Class.new(FatalException)
  end
end
