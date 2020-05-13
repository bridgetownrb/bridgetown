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

    # compatibility layer for octopress-hooks users
    PRIORITY_MAP = {
      low: 10,
      normal: 20,
      high: 30,
    }.freeze

    # initial empty hooks
    @registry = {}

    NotAvailable = Class.new(RuntimeError)
    Uncallable = Class.new(RuntimeError)

    # Ensure the priority is a Fixnum
    def self.priority_value(priority)
      return priority if priority.is_a?(Integer)

      PRIORITY_MAP[priority] || DEFAULT_PRIORITY
    end

    # register hook(s) to be called later
    def self.register(owners, event, priority: DEFAULT_PRIORITY, reloadable: true, &block)
      Array(owners).each do |owner|
        register_one(owner, event, priority: priority, reloadable: reloadable, &block)
      end
    end

    # register a single hook to be called later
    def self.register_one(owner, event, priority: DEFAULT_PRIORITY, reloadable: true, &block)
      @registry[owner] ||= []

      raise Uncallable, "Hooks must respond to :call" unless block.respond_to? :call

      @registry[owner] << HookRegistration.new(
        owner: owner,
        event: event,
        priority: priority_value(priority),
        reloadable: reloadable,
        block: block
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

    def self.remove_hook(owner, _event, block)
      @registry[owner].delete_if { |item| item.block == block }
    end

    def self.trigger(owner, event, *args)
      # proceed only if there are hooks to call
      hooks = @registry[owner]&.select { |item| item.event == event }
      return if hooks.nil? || hooks.empty?

      prioritized_hooks(hooks).each do |hook|
        if ENV["BRIDGETOWN_LOG_LEVEL"] == "debug"
          hook_info = args[0]&.respond_to?(:url) ? args[0].relative_path : hook.block
          Bridgetown.logger.debug("Triggering hook:", "#{owner}:#{event} for #{hook_info}")
        end
        hook.block.call(*args)
      end
    end

    def self.prioritized_hooks(hooks)
      # sort hooks according to priority and load order
      grouped_hooks = hooks.group_by(&:priority)
      grouped_hooks.keys.sort.reverse.map { |priority| grouped_hooks[priority] }.flatten
    end

    def self.clear_reloadable_hooks
      Bridgetown.logger.debug("Clearing reloadable hooks")

      @registry.each_value do |hooks|
        hooks.delete_if(&:reloadable)
      end
    end
  end
end
