# frozen_string_literal: true

module Bridgetown
  module Site::Renderable
    # Render the site to the destination.
    # @return [void]
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
    # @see Bridgetown::Site::Content#site_payload
    def render_docs
      collections.each_value do |collection|
        collection.docs.each do |document|
          render_regenerated document
        end
      end
    end

    # Renders all pages
    # @return [void]
    # @see Bridgetown::Site::Content#site_payload
    def render_pages
      pages.each do |page|
        render_regenerated page
      end
    end

    # Regenerates a site using {Bridgetown::Renderer}
    # @param document [Post] The document to regenerate.
    # @return [void]
    # @see Bridgetown::Renderer
    def render_regenerated(document)
      return unless regenerator.regenerate?(document)

      Bridgetown::Renderer.new(self, document).run
    end
  end
end
