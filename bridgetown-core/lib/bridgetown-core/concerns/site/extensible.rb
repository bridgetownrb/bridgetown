# frozen_string_literal: true

module Bridgetown
  module Site::Extensible
    # Load necessary libraries, plugins, converters, and generators.
    # @see Bridgetown::Converter
    # @see Bridgetown::Generator
    # @see PluginManager
    # @return [void]
    def setup
      plugin_manager.require_plugin_files
      plugin_manager.setup_component_loaders
      self.converters = instantiate_subclasses(Bridgetown::Converter)
      self.generators = instantiate_subclasses(Bridgetown::Generator)
    end

    # Run all Generators.
    # @see Bridgetown::Generator
    # @return [void]
    def generate
      generators.each do |generator|
        start = Time.now
        generator.generate(self)

        next unless ENV["BRIDGETOWN_LOG_LEVEL"] == "debug"

        generator_name = if generator.class.respond_to?(:custom_name)
                           generator.class.custom_name
                         else
                           generator.class.name
                         end
        Bridgetown.logger.debug "Generating:",
                                "#{generator_name} finished in #{Time.now - start} seconds."
      end
    end

    # Get the implementation class for the given Converter.
    # @param klass [Object] The Class of the Converter to fetch.
    # @return [Bridgetown::Converter] Returns the {Bridgetown::Converter}
    #   instance implementing the given +Converter+.
    def find_converter_instance(klass)
      @find_converter_instance ||= {}
      @find_converter_instance[klass] ||= begin
        converters.find { |converter| converter.instance_of?(klass) } || \
          raise("No Converters found for #{klass}")
      end
    end

    # Create an array of instances of the subclasses of the class or module
    #   passed in as argument.
    # @param klass [Class, Module] - class or module containing the subclasses.
    # @return [Array<Object>] Returns an array of instances of subclasses of
    #   +klass+.
    def instantiate_subclasses(klass)
      klass.descendants.sort.map do |c|
        c.new(config)
      end
    end
  end
end
