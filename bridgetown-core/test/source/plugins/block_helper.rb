# frozen_string_literal: true

module BlockHelper
  Bridgetown::RubyTemplateView::Helpers.class_eval do
    def test_block_helpers(&block)
      block_text = view.capture({ value: "value" }, &block)

      "+Value: #{block_text.strip}+\n"
    end
  end
end
