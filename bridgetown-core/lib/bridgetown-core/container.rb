# frozen_string_literal: true

module Bridgetown
  class Container < Async::Container::Forked
    require_relative "container/interceptor"
    require_relative "container/policy"

    def initialize(**options)
      @routines = {}

      super(policy: Policy.new, **options)
    end

    def add_routine(routine)
      @routines[routine.key] = routine
    end

    def run
      Process.setproctitle(
        "Bridgetown #{Bridgetown::VERSION} " \
        "— Parent Container [#{File.basename(Dir.pwd)}]"
      )

      @routines.each do |key, routine|
        interceptor = nil
        interceptor = Interceptor.with_tag(routine.tag[:value], color: routine.tag[:color]) \
          if routine.respond_to?(:tag)

        spawn(name: routine.name, key: key) do |instance|
          interceptor&.hook

          routine.execute(instance)
        end
      end
    end
  end
end
