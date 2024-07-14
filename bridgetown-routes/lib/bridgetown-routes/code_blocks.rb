# frozen_string_literal: true

module Bridgetown
  module Routes
    module CodeBlocks
      class << self
        attr_accessor :blocks

        def add_route(name, file_code = nil, front_matter_line_count = nil, &block)
          block.instance_variable_set(:@_route_file_code, file_code) if file_code
          if front_matter_line_count
            block.instance_variable_set(:@_front_matter_line_count, front_matter_line_count)
          end

          @blocks ||= {}
          @blocks[name] = block
        end

        # @param name [String]
        def route_defined?(name)
          blocks&.key?(name)
        end

        def route_block(name)
          blocks[name] if route_defined?(name)
        end

        def eval_route_file(file, file_slug, app) # rubocop:disable Lint/UnusedMethodArgument
          if Bridgetown.env.production? && Bridgetown::Routes::CodeBlocks.route_defined?(file_slug)
            # we don't need to re-eval the file in production because it won't be changing underfoot
            return
          end

          code = File.read(file)
          code_postmatch = nil
          ruby_content = code.match(Bridgetown::FrontMatter::Loaders::Ruby::BLOCK)
          front_matter_line_count = nil
          if ruby_content
            code = ruby_content[1]
            code_postmatch = ruby_content.post_match.lstrip
            front_matter_line_count = code.lines.count - 1
            if code.match?(%r!^\s*render_with(\s|\()!).! && code.match?(%r!r\.[a-z]+\s+do!).!
              code.concat("\nrender_with {}")
            end
          end

          # rubocop:disable Style/DocumentDynamicEvalDefinition, Style/EvalWithLocation
          code_proc = Kernel.eval(
            "proc {|r| #{code} }", TOPLEVEL_BINDING, file, ruby_content ? 2 : 1
          )
          add_route(file_slug, code_postmatch, front_matter_line_count, &code_proc)
          # rubocop:enable Style/DocumentDynamicEvalDefinition, Style/EvalWithLocation
        end
      end
    end
  end
end
