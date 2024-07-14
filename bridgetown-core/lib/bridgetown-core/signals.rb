# frozen_string_literal: true

require "signalize/struct"

class Bridgetown::Signals < Signalize::Struct
  alias_method :__prev_to_h, :to_h
  include Enumerable
  alias_method :to_h, :__prev_to_h

  def self.signal_accessor(...)
    super

    return unless members.include?(:members)

    # So…we need to support site data that could have a `members` key. This is how we do it:
    # by conditionally providing the value the gem class expects when it's gem code, otherwise we
    # provide the `members` signal value.
    define_method :members do
      if caller_locations(1..1).first.path.end_with?("/lib/signalize/struct.rb")
        self.class.members
      else
        members_signal.value
      end
    end
  end

  def each(...)
    to_h.each(...)
  end

  def key?(key)
    self.class.members.include?(key.to_sym)
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

    super(key.to_sym)
  end

  # You can access signals and mutate objects (aka push to an array, change a hash value), and by
  # making those changes with a block, this method will track which signals were accessed and resave
  # them with duplicated objects thereby triggering new dependent effects or subscriptions.
  def batch_mutations
    ef = Signalize.effect { yield self }
    node = ef.receiver._sources
    deps = []
    while node
      deps << node._source
      node = node._next_source
    end

    ef.() # dispose

    Signalize.batch do
      self.class.members.each do |member_name|
        matching_dep = deps.find { _1 == send(:"#{member_name}_signal") }
        next unless matching_dep

        Signalize.batch do
          new_value = matching_dep.value.dup
          matching_dep.value = nil
          matching_dep.value = new_value
        end
      end
    end

    nil
  end
end
