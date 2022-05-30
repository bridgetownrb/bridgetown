# frozen_string_literal: true

module Bridgetown
  module Routes
    module CodeBlocks
      class << self
        attr_accessor :blocks

        def add_route(name, file_code = nil, &block)
          block.instance_variable_set(:@_route_file_code, file_code) if file_code

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
          ruby_content = code.match(Bridgetown::FrontMatterImporter::RUBY_BLOCK)
          if ruby_content
            code = ruby_content[1]
            code_postmatch = ruby_content.post_match
          end

          code = <<~RUBY
            add_route(#{file_slug.inspect}, #{code_postmatch.inspect}) do |r|
              #{code}
            end
          RUBY
          instance_eval(code, file, ruby_content ? 1 : 0)
        end
      end
    end
  end
end
