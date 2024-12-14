# frozen_string_literal: true

module Bridgetown
  # This mixin for Bridgetown components allows you to provide front matter and render
  # the component template via the layouts transformation pipeline, which can be called
  # from any Roda route
  module Viewable
    include Bridgetown::RodaCallable
    include Bridgetown::Transformable

    def site
      @site ||= Bridgetown::Current.site
    end

    def data
      @data ||= HashWithDotAccess::Hash.new
    end

    def front_matter(&block)
      Bridgetown::FrontMatter::RubyFrontMatter.new(data:).tap { _1.instance_exec(&block) }
    end

    def relative_path = self.class.source_location.delete_prefix("#{site.root_dir}/")

    # Render the component template in the layout specified in your front matter
    #
    # @param app [Roda]
    def render_in_layout(app)
      render_in(app) => rendered_output

      site.validated_layouts_for(self, data.layout).each do |layout|
        transform_with_layout(layout, rendered_output, self) => rendered_output
      end

      rendered_output
    end

    # Pass a block of front matter and render the component template in layouts
    #
    # @param app [Roda]
    def render_with(app, &)
      front_matter(&)
      render_in_layout(app)
    end
  end
end
