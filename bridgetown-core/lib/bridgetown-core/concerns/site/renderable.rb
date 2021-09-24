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

    def matched_converters_for_convertible(convertible)
      @layout_converters ||= {}

      if convertible.is_a?(Bridgetown::Layout) && @layout_converters[convertible]
        return @layout_converters[convertible]
      end

      matches = converters.select do |converter|
        if converter.method(:matches).arity == 1
          converter.matches(convertible.extname)
        else
          converter.matches(convertible.extname, convertible)
        end
      end

      @layout_converters[convertible] = matches if convertible.is_a?(Bridgetown::Layout)

      matches
    end

    # Renders all documents
    # @return [void]
    def render_docs
      collections.each_value do |collection|
        collection.docs.each do |document|
          render_with_locale(document) do
            render_item document
          end
        end

        collection.resources.each do |resource|
          render_with_locale(resource) do
            resource.transform!
          end
        end
      end
    end

    # Renders all pages
    # @return [void]
    def render_pages
      pages.each do |page|
        render_item page
      end
    end

    # Renders a content item while ensuring site locale is set if the data is available.
    # @param item [Document, Page, Bridgetown::Resource::Base] The item to render
    # @yield Runs the block in between locale setting and resetting
    # @return [void]
    def render_with_locale(item)
      if item.data["locale"]
        previous_locale = locale
        self.locale = item.data["locale"]
        yield
        self.locale = previous_locale
      else
        yield
      end
    end

    # Regenerates a content item using {Renderer}
    # @param item [Document, Page] The document or page to regenerate.
    # @return [void]
    def render_item(item)
      Bridgetown::Renderer.new(self, item).run
    end
  end
end
