# frozen_string_literal: true

require "signalize/struct"

class Bridgetown::Signals < Signalize::Struct
  def key?(key)
    members.include?(key.to_sym)
  end

  def [](key)
    return unless key?(key)

    send(key)
  end

  def []=(key, value)
    unless key?(key)
      if instance_of?(Bridgetown::Signals)
        raise Bridgetown::Errors::FatalException,
              "You must use a unique subclass of `Bridgetown::Signals' before adding new members"
      end

      self.class.signal_accessor(key)
    end

    send(:"#{key}=", value)
  end

  def method_missing(key, *value, &block) # rubocop:disable Style/MissingRespondToMissing
    return nil if value.empty? && block.nil?

    key = key.to_s
    if key.end_with?("=")
      key.chop!
      return self[key] = value[0]
    end

    super
  end
end
