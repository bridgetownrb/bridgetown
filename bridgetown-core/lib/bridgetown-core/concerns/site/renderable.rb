# frozen_string_literal: true

module Bridgetown
  module Site::Renderable
    # Render the site to the destination.
    # @return [void]
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
    # @param payload [Hash] A hash of site data.
    # @return [void]
    # @see Bridgetown::Site::Content#site_payload
    def render_docs(payload)
      collections.each_value do |collection|
        collection.docs.each do |document|
          render_with_locale(document) do
            render_regenerated(document, payload)
          end
        end
      end
    end

    # Renders all pages
    # @param payload [Hash] A hash of site data.
    # @return [void]
    # @see Bridgetown::Site::Content#site_payload
    def render_pages(payload)
      pages.each do |page|
        render_regenerated(page, payload)
      end
    end

    # Renders a document while ensuring site locale is set if the data is available.
    # @param document [Bridgetown::Document] The document to render
    # @yield Runs the block in between locale setting and resetting
    # @return [void]
    def render_with_locale(document)
      if document.data["locale"]
        previous_locale = locale
        self.locale = document.data["locale"]
        yield
        self.locale = previous_locale
      else
        yield
      end
    end

    # Regenerates a site using {Bridgetown::Renderer}
    # @param document [Post] The document to regenerate.
    # @param payload [Hash] A hash of site data.
    # @return [void]
    # @see Bridgetown::Renderer
    def render_regenerated(document, payload)
      return unless regenerator.regenerate?(document)

      Bridgetown::Renderer.new(self, document, payload).run
    end
  end
end
