# frozen_string_literal: true

module Bridgetown
  module Builders
    class VirtualGenerator < Bridgetown::Generator
      priority :high

      def self.add(path, block)
        @documents_to_generate ||= []
        @documents_to_generate << [path, block]
      end

      class << self
        attr_reader :documents_to_generate
      end

      def self.clear_documents_to_generate
        @documents_to_generate = []
      end

      def generate(site)
        self.class.documents_to_generate&.each do |doc_block|
          path, block = doc_block
          doc_builder = DocumentBuilder.new(site, path)
          doc_builder.instance_exec(&block)
          doc_builder._add_document_to_site
        end
      end
    end
  end
end
