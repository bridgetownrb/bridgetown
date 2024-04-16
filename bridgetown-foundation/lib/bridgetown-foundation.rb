# frozen_string_literal: true

require "bridgetown/foundation/version"
require "zeitwerk"

class Module
  # Due to Active Support incompatibility, we can't extend Gem::Deprecate directly in `Object`
  # So we're pulling this in as `gem_deprecate` from `deprecate`:
  # https://github.com/rubygems/rubygems/blob/v3.5.9/lib/rubygems/deprecate.rb
  #
  # Pass in the deprecated method name, the new method name, and the year & month it'll be removed
  #
  # @param name [Symbol] e.g. `:howdy`
  # @param repl [Symbol] e.g. `:hello`
  # @param year [Integer] e.g. `2025`
  # @param month [Integer] e.g. `1` for January
  def gem_deprecate(name, repl, year, month)
    # rubocop:disable Style/FormatStringToken
    class_eval do
      old = "_deprecated_#{name}"
      alias_method old, name
      define_method name do |*args, &block|
        klass = is_a? Module
        target = klass ? "#{self}." : "#{self.class}#"
        msg = [
          "NOTE: #{target}#{name} is deprecated",
          repl == :none ? " with no replacement" : "; use #{repl} instead",
          format(". It will be removed on or after %4d-%02d.", year, month),
          "\n#{target}#{name} called from #{Gem.location_of_caller.join(":")}",
        ]
        warn "#{msg.join}." unless Gem::Deprecate.skip
        send old, *args, &block
      end
    end
    # rubocop:enable Style/FormatStringToken
  end
end

Zeitwerk.with_loader do |l|
  l.push_dir "#{__dir__}/bridgetown/foundation", namespace: Bridgetown::Foundation
  l.ignore "#{__dir__}/bridgetown/foundation/version.rb"
  #l.ignore "#{__dir__}/bridgetown/foundation/core_ext/string.rb"
  l.setup
  l.eager_load
end
