# frozen_string_literal: true

module Bridgetown
  class Component
    extend Forwardable

    def_delegators :@_parent_view_context, :render, :liquid_render, :helpers

    class << self
      attr_accessor :source_location

      def inherited(child)
        # Code cribbed from ViewComponent by GitHub:
        # Derive the source location of the component Ruby file from the call stack
        child.source_location = caller_locations(1, 10).reject do |l|
          l.label == "inherited"
        end[0].absolute_path

        super
      end

      def renderer_for_ext(ext, &block)
        case ext
        when "erb"
          Tilt::ErubiTemplate.new(
            component_template_path,
            outvar: "@_erbout",
            bufval: "Bridgetown::ERBBuffer.new",
            engine_class: Bridgetown::ERBEngine,
            &block
          )
        when "serb" # requires serbea
          include Serbea::Helpers
          Tilt::SerbeaTemplate.new(component_template_path, &block)
        when "slim" # requires bridgetown-slim
          Slim::Template.new(component_template_path, &block)
        when "haml" # requires bridgetown-haml
          Tilt::HamlTemplate.new(component_template_path, &block)
        else
          raise "No component rendering engine could be found for .#{ext} templates"
        end
      end

      def component_template_path
        stripped_path = File.join(
          File.dirname(source_location),
          File.basename(source_location, ".*")
        )
        supported_template_extensions.each do |ext|
          test_path = "#{stripped_path}.#{ext}"
          return test_path if File.exist?(test_path)

          test_path = "#{stripped_path}.html.#{ext}"
          return test_path if File.exist?(test_path)
        end

        raise "No matching templates could be found in #{File.dirname(source_location)}"
      end

      def component_template_content
        File.read(component_template_path)
      end

      def supported_template_extensions
        %w(erb serb slim haml)
      end
    end

    def content
      @_content_block&.call
    end

    def render_in(view_context, &block)
      @_parent_view_context = view_context
      @_content_block = block

      before_render

      if render?
        template
      else
        ""
      end
    end

    def template
      call || _renderer.render(self)
    end

    def call
      nil
    end

    def before_render; end

    def render?
      true
    end

    def _renderer
      @_renderer ||= begin
        ext = File.extname(self.class.component_template_path).delete_prefix(".")
        self.class.renderer_for_ext(ext) { self.class.component_template_content }
      end
    end

    def method_missing(method, *args, &block)
      if helpers.respond_to?(method.to_sym)
        helpers.send method.to_sym, *args, &block
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      helpers.respond_to?(method.to_sym, include_private) || super
    end
  end
end
