# frozen_string_literal: true

module RuboCop
  module Cop
    module Bridgetown
      # TODO: relocate to the rubocop-bridgetown gem!
      class HTMLEscapedHeredoc < Cop
        include Heredoc

        MSG = "Insecure HEREDOC detected. Use `html`, `html_map`, `text`, or `render` inside interpolation."

        def on_heredoc(node)
          return unless node.source.match?(%r!HTML$!) && heredoc_body(node).match?(%r%[^\\]#\{(?!\s*?(html|html_map|text|render)[ \-])%)

          add_offense(node, message: MSG)
        end

        private

        def heredoc_body(node)
          node.loc.heredoc_body.source
        end
      end
    end
  end
end
