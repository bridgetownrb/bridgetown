# frozen_string_literal: true

class Bridgetown::Site
  module Extensible
    # Load necessary libraries, plugins, converters, and generators.
    # This is only ever run once for the lifecycle of the site object.
    # @see Converter
    # @see Generator
    # @see PluginManager
    # @return [void]
    def setup
      plugin_manager.require_plugin_files
      loaders_manager.setup_loaders
      self.converters = instantiate_subclasses(Bridgetown::Converter)
      self.generators = instantiate_subclasses(Bridgetown::Generator)
    end

    # Run all Generators.
    # @see Generator
    # @return [void]
    def generate
      generators.each do |generator|
        start = Time.now
        generator.generate(self)

        next unless ENV["BRIDGETOWN_LOG_LEVEL"] == "debug"

        generator_name = generator.class.respond_to?(:custom_name) ?
                           generator.class.custom_name :
                           generator.class.name
        Bridgetown.logger.debug "Generating:",
                                "#{generator_name} finished in #{Time.now - start} seconds."
      end
    end

    # Get the implementation for the given Converter class.
    # @param klass [Class] The Class of the Converter to fetch.
    # @return [Converter] Returns the {Converter}
    #   instance implementing the given `Converter` class.
    def find_converter_instance(klass)
      @find_converter_instance ||= {}
      @find_converter_instance[klass] ||= converters.find do |converter|
        converter.instance_of?(klass)
      end || raise("No Converters found for #{klass}")
    end

    # Create an array of instances of the subclasses of the class
    #   passed in as argument.
    # @param klass [Class] - class which is the parent of the subclasses.
    # @return [Array<Converter, Generator>] Returns an array of instances of
    #   subclasses of `klass`.
    def instantiate_subclasses(klass)
      klass.descendants.sort.map do |c|
        c.new(config)
      end
    end

    # Shorthand for registering a site hook via {Bridgetown::Hooks}
    # @param event [Symbol] name of the event (`:pre_read`, `:post_render`, etc.)
    # @yield the block will be called when the event is triggered
    # @yieldparam site the site which triggered the event hook
    def on(event, reloadable: false, &)
      Bridgetown::Hooks.register_one :site, event, reloadable:, &
    end
  end
end
