# frozen_string_literal: true

module Bridgetown
  module Hooks
    HookRegistration = Struct.new(
      :owner,
      :event,
      :priority,
      :reloadable,
      :block,
      keyword_init: true
    ) do
      def to_s
        "#{owner}:#{event} for #{block}"
      end
    end

    DEFAULT_PRIORITY = 20

    PRIORITY_MAP = {
      low: 10,
      normal: 20,
      high: 30,
    }.freeze

    @registry = {}

    NotAvailable = Class.new(RuntimeError)
    Uncallable = Class.new(RuntimeError)

    def self.priority_value(priority)
      return priority if priority.is_a?(Integer)

      PRIORITY_MAP[priority] || DEFAULT_PRIORITY
    end

    # Sort registered hooks according to priority and load order
    #
    # @param hooks [Array<HookRegistration>]
    def self.prioritized_hooks(hooks)
      grouped_hooks = hooks.group_by(&:priority)
      grouped_hooks.keys.sort.reverse.map { |priority| grouped_hooks[priority] }.flatten
    end

    # Register one or more hooks which may be triggered later for a particular event
    #
    # @param owners [Symbol, Array<Symbol>] name of the owner (`:site`, `:resource`, etc.)
    # @param event [Symbol] name of the event (`:pre_read`, `:post_render`, etc.)
    # @param priority [Integer, Symbol] either `:low`, `:normal`, or `:high`, or an integer.
    #   Default is normal (20)
    # @param reloadable [Boolean] whether the hook should be removed prior to a site reload.
    #   Default is true.
    # @yield the block will be called when the event is triggered. Typically it receives at
    #   least one argument.
    # @yieldparam obj the object which triggered the event hook
    def self.register(owners, event, priority: DEFAULT_PRIORITY, reloadable: true, &block)
      Array(owners).each do |owner|
        register_one(owner, event, priority:, reloadable:, &block)
      end
    end

    # Register a hook which may be triggered later for a particular event
    #
    # @param owner [Symbol] name of the owner (`:site`, `:resource`, etc.)
    # @param event [Symbol] name of the event (`:pre_read`, `:post_render`, etc.)
    # @param priority [Integer, Symbol] either `:low`, `:normal`, or `:high`, or an integer.
    #   Default is normal (20)
    # @param reloadable [Boolean] whether the hook should be removed prior to a site reload.
    #   Default is true.
    # @yield the block will be called when the event is triggered. Typically it receives at
    #   least one argument.
    # @yieldparam obj the object which triggered the event hook
    # @return [Proc] the block that was pased in
    def self.register_one(owner, event, priority: DEFAULT_PRIORITY, reloadable: true, &block)
      @registry[owner] ||= []

      raise Uncallable, "Hooks must respond to :call" unless block.respond_to? :call

      @registry[owner] << HookRegistration.new(
        owner:,
        event:,
        priority: priority_value(priority),
        reloadable:,
        block:
      )
      if ENV["BRIDGETOWN_LOG_LEVEL"] == "debug"
        if Bridgetown.respond_to?(:logger)
          Bridgetown.logger.debug("Registering hook:", @registry[owner].last.to_s)
        else
          p "Registering hook:", @registry[owner].last.to_s
        end
      end

      block
    end

    # Delete a previously-registered hook
    #
    # @param owners [Symbol] name of the owner (`:site`, `:resource`, etc.)
    # @param block [Proc] the exact block used originally to register the hook
    def self.remove_hook(owner, block)
      @registry[owner].delete_if { |item| item.block == block }
    end

    # Clear all hooks marked as reloadable from the registry
    def self.clear_reloadable_hooks
      Bridgetown.logger.debug("Clearing reloadable hooks")

      @registry.each_value do |hooks|
        hooks.delete_if(&:reloadable)
      end
    end

    # Trigger all registered hooks for a particular owner and event.
    # Any arguments after the initial two will be directly passed along to the hooks.
    #
    # @param owner [Symbol] name of the owner (`:site`, `:resource`, etc.)
    # @param event [Symbol] name of the event (`:pre_read`, `:post_render`, etc.)
    def self.trigger(owner, event, *args) # rubocop:disable Metrics/CyclomaticComplexity
      # proceed only if there are hooks to call
      hooks = @registry[owner]&.select { |item| item.event == event }
      return if hooks.nil? || hooks.empty?

      prioritized_hooks(hooks).each do |hook|
        if ENV["BRIDGETOWN_LOG_LEVEL"] == "debug"
          hook_info = args[0].respond_to?(:relative_path) ? args[0].relative_path : hook.block
          Bridgetown.logger.debug("Triggering hook:", "#{owner}:#{event} for #{hook_info}")
        end
        hook.block.call(*args)
      end

      true
    end
  end
end
