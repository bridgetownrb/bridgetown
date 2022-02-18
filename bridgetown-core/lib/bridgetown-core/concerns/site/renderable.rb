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
      render_resources
      generated_pages.each(&:transform!)
      Bridgetown::Hooks.trigger :site, :post_render, self
    end

    # Executes procs in Ruby frontmatter
    #
    # @return [void]
    # @see https://www.bridgetownrb.com/docs/front-matter#ruby-front-matter
    def execute_inline_ruby_for_layouts!
      return unless config.should_execute_inline_ruby?

      layouts.each_value do |layout|
        Bridgetown::Utils::RubyExec.search_data_for_ruby_code(layout)
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

    # @return [Array<Bridgetown::Layout>]
    def validated_layouts_for(convertible, layout_name)
      layout = layouts[layout_name]
      warn_on_missing_layout convertible, layout, layout_name

      layout_list = Set.new([layout])
      while layout
        layout_name = layout.data.layout
        layout = layouts[layout_name]
        warn_on_missing_layout convertible, layout, layout_name

        layout_list << layout
      end

      layout_list.to_a.compact
    end

    def warn_on_missing_layout(convertible, layout, layout_name)
      return unless layout.nil? && layout_name

      Bridgetown.logger.warn(
        "Build Warning:",
        "Layout '#{layout_name}' requested via #{convertible.relative_path} does not exist."
      )
    end

    # Renders all resources
    # @return [void]
    def render_resources
      collections.each_value do |collection|
        collection.resources.each do |resource|
          render_with_locale(resource) do
            resource.transform!
          end
        end
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
  end
end
