# frozen_string_literal: true

module Bridgetown
  module Site::Extensible
    # Load necessary libraries, plugins, converters, and generators.
    #
    # Returns nothing.
    def setup
      plugin_manager.require_plugin_files
      self.converters = instantiate_subclasses(Bridgetown::Converter)
      self.generators = instantiate_subclasses(Bridgetown::Generator)
    end

    # Run each of the Generators.
    #
    # Returns nothing.
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
    # Returns the Converter instance implementing the given Converter.
    # klass - The Class of the Converter to fetch.
    def find_converter_instance(klass)
      @find_converter_instance ||= {}
      @find_converter_instance[klass] ||= begin
        converters.find { |converter| converter.instance_of?(klass) } || \
          raise("No Converters found for #{klass}")
      end
    end

    # klass - class or module containing the subclasses.
    # Returns array of instances of subclasses of parameter.
    # Create array of instances of the subclasses of the class or module
    # passed in as argument.

    def instantiate_subclasses(klass)
      klass.descendants.sort.map do |c|
        c.new(config)
      end
    end
  end
end
