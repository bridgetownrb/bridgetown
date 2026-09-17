module Bridgetown
  module Utils
    class Callouts
      class DefaultCallout < Bridgetown::Component
        CALLOUT_ICONS =
          {
            note: "🗒️",
            tip: "💡",
            important: "💬",
            warning: "⚠️",
            caution: "🚨",
          }.freeze

        STYLESHEET =
          <<~CSS
            blockquote.bt-callout {
              border-inline-start: var(--bt-callout-border-width, 5px) solid var(--bt-callout-border-color, darkslategray);
              margin-inline: 0;
              padding: 0.33lh 0.75lh;

              > *:last-child {
                margin-block-end: 0;
              }

              > header {
                display: flex;
                gap: 0.5em;
                margin-block-end: 0.5lh;

                > bt-label {
                  font-weight: bold;
                }
              }
            }
          CSS

        def initialize(type:, resource:)
          @type, @resource = type, resource

          @icon = CALLOUT_ICONS[type]
        end

        def template
          html -> { <<~HTML
            {: .bt-callout .bt-callout-#{text->{@type}}}
            > <header><bt-icon>#{text->{@icon}}</bt-icon> <bt-label>#{text->{@type.to_s.capitalize}}</bt-label></header>
            >
            #{html->{content.lstrip}}
          HTML
          }
        end
      end

      # @param config [Bridgetown::Configuration::ConfigurationDSL]
      # @param componnet_class_name [String]
      def self.setup_parsing_hook(config, component_class_name)
        markdown_exts = config.markdown_ext.split(",").map { ".#{_1}" }

        config.hook :resources, :pre_render, priority: :low do |resource|
          next unless markdown_exts.include?(resource.relative_path.extname)
          next if resource.data.bypass_callouts

          Callouts.new(resource:, component_class_name:).convert
        end
      end

      # @param resource [Bridgetown::Resource::Base]
      def initialize(resource:, component_class_name:)
        @resource = resource
        @component_class_name = component_class_name
        @site = resource.site

        @delims = Bridgetown::Converter.subclasses.find {|converter| converter.template_engine == resource.data.template_engine}&.helper_delimiters
      end

      def convert
        return unless @delims # can't proceed if we don't know if we're in an ERB or Searbea context

        # icons = {
        #   note: "🗒️",
        #   tip: "💡",
        #   important: "💬",
        #   warning: "⚠️",
        #   caution: "🚨"
        # }

        content_lines = @resource.content.lines

        ## FIRST STEP
        full_matches = []
        starting_line_index = nil
        callout_type = nil

        content_lines.each_with_index do |line, index|
          if starting_line_index && line.start_with?(">")
            next
          elsif starting_line_index
            full_matches << [callout_type, starting_line_index, index - 1]
            starting_line_index = nil
            callout_type = nil
          end

          matched = line.match(%r!^\> \[\!(.*?)\]$!)
          next unless matched

          callout_type = Regexp.last_match[1].downcase.to_sym
          starting_line_index = index
        end

        # consider last line matching
        if starting_line_index
          full_matches << [callout_type, starting_line_index, content_lines.length - 1]
          starting_line_index = nil
          callout_type = nil
        end

        return unless full_matches.length.positive?

        ## IT WORKS. Now I just gotta carve up the original string

        new_content = []
        new_starting_line = nil
        full_matches.each_with_index do |match, index|
          if index == 0
            new_content << content_lines[0...match[1]].join
          else
            new_content << content_lines[new_starting_line...match[1]].join
          end
          callout_content = content_lines[(match[1] + 1)..match[2]].join
          rep = "#{@delims[0]} render #{@component_class_name}.new(type: :#{match[0]}, resource:) do #{@delims[1]}\n#{callout_content}#{@delims[0].delete_suffix("=")} end #{@delims[1]}"
          new_content << rep
          new_starting_line = match[2] + 1

          if index == full_matches.length - 1
            new_content << content_lines[new_starting_line...].join
          end
        end

        @resource.content = new_content.join
      end
    end
  end
end
