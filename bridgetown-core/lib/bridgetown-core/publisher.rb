# frozen_string_literal: true

module Bridgetown
  class Publisher
    # @param site [Bridgetown::Site]
    def initialize(site)
      @site = site
    end

    def publish?(thing)
      can_be_published?(thing) && !hidden_in_the_future?(thing)
    end

    def hidden_in_the_future?(thing)
      return false unless thing.respond_to?(:date)

      future_allowed =
        (thing.respond_to?(:collection) && thing.collection.metadata.future) || @site.config.future
      thing_time = thing.date.is_a?(Date) ? thing.date.to_time.to_i : thing.date.to_i
      !future_allowed && thing_time > @site.time.to_i
    end

    private

    def can_be_published?(thing)
      thing.data.fetch("published", true) || @site.config.unpublished
    end
  end
end
