# frozen_string_literal: true

class Bridgetown::Site
  module Renderable
    # Render all pages & documents so they're ready to be written out to disk.
    # @return [void]
    # @see Page
    # @see Document
    def render
      payload = site_payload

      Bridgetown::Hooks.trigger :site, :pre_render, self, payload

      execute_inline_ruby_for_layouts!

      render_docs(payload)
      render_pages(payload)

      Bridgetown::Hooks.trigger :site, :post_render, self, payload
    end

    # Executes inline Ruby frontmatter
    #
    # @example
    #   calculation: !ruby/string:Rb |
    #     [2 * 4, 5 + 2].min
    # @return [void]
    # @see https://www.bridgetownrb.com/docs/front-matter#ruby-front-matter
    def execute_inline_ruby_for_layouts!
      return unless config.should_execute_inline_ruby?

      layouts.each_value do |layout|
        Bridgetown::Utils::RubyExec.search_data_for_ruby_code(layout, self)
      end
    end

    # Renders all documents
    # @return [void]
    def render_docs(payload)
      collections.each_value do |collection|
        collection.docs.each do |document|
          render_regenerated(document, payload)
        end
      end
    end

    # Renders all pages
    # @return [void]
    def render_pages(payload)
      pages.each do |page|
        render_regenerated(page, payload)
      end
    end

    # Regenerates a site using {Renderer}
    # @param document [Post] The document to regenerate.
    # @return [void]
    def render_regenerated(document, payload)
      return unless regenerator.regenerate?(document)

      Bridgetown::Renderer.new(self, document, payload).run
    end
  end
end
