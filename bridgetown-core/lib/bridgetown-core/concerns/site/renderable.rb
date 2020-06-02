# frozen_string_literal: true

module Bridgetown
  module Site::Renderable
    # Render the site to the destination.
    #
    # Returns nothing.
    def render
      payload = site_payload

      Bridgetown::Hooks.trigger :site, :pre_render, self, payload

      execute_inline_ruby_for_layouts!

      render_docs(payload)
      render_pages(payload)

      Bridgetown::Hooks.trigger :site, :post_render, self, payload
    end

    def execute_inline_ruby_for_layouts!
      return unless config.should_execute_inline_ruby?

      layouts.each_value do |layout|
        Bridgetown::Utils::RubyExec.search_data_for_ruby_code(layout, self)
      end
    end

    def render_docs(payload)
      collections.each_value do |collection|
        collection.docs.each do |document|
          render_regenerated(document, payload)
        end
      end
    end

    def render_pages(payload)
      pages.each do |page|
        render_regenerated(page, payload)
      end
    end

    def render_regenerated(document, payload)
      return unless regenerator.regenerate?(document)

      Bridgetown::Renderer.new(self, document, payload).run
    end
  end
end
