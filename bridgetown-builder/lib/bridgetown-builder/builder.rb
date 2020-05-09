# frozen_string_literal: true

module Bridgetown
  # Superclass for a website's SiteBuilder abstract class
  class Builder < Bridgetown::Builders::PluginBuilder
    def initialize(name, current_site = nil)
      super(name, current_site)
      build
    end

    def build
      # subclass
    end

    def inspect
      name
    end

    def self.inherited(const)
      (@children ||= Set.new).add const
      catch_inheritance(const) do |const_|
        catch_inheritance(const_)
      end
    end

    def self.catch_inheritance(const)
      const.define_singleton_method :inherited do |const_|
        (@children ||= Set.new).add const_
        yield const_ if block_given?
      end
    end

    def self.descendants
      @children ||= Set.new
      out = @children.map(&:descendants)
      out << self unless name == "SiteBuilder"
      Set.new(out).flatten
    end
  end
end
