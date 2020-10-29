# frozen_string_literal: true

class Bridgetown::Site
  module Renderable
    # Render all pages & documents so they're ready to be written out to disk.
    # @return [void]
    # @see Page
    # @see Document
    def render
      Bridgetown::Hooks.trigger :site, :pre_render, self
      execute_inline_ruby_for_layouts!
      render_docs
      render_pages
      Bridgetown::Hooks.trigger :site, :post_render, self
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
    def render_docs
      collections.each_value do |collection|
        collection.docs.each do |document|
          render_with_locale(document) do
            render_regenerated document
          end
        end
      end
    end

    # Renders all pages
    # @return [void]
    def render_pages
      pages.each do |page|
        render_regenerated page
      end
    end

    # Renders a document while ensuring site locale is set if the data is available.
    # @param document [Document] The document to render
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

    # Regenerates a site using {Renderer}
    # @param document [Document] The document to regenerate.
    # @return [void]
    def render_regenerated(document)
      return unless regenerator.regenerate?(document)

      Bridgetown::Renderer.new(self, document).run
    end
  end
end
