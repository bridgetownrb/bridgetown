# frozen_string_literal: true

module Bridgetown
  module Commands
    class Notes < Thor::Group
      extend Summarizable

      Registrations.register do
        register(Notes, "notes", "notes", Notes.summary)
      end

      def self.banner
        "bridgetown notes [options]"
      end
      summary "Lists annotations in the current site"

      class_option :annotations,
                   type: :array,
                   aliases: "-a",
                   desc: "Filter by specific annotations, e.g. Foobar TODO"
      def list
        annotations = options[:annotations] || Bridgetown::Utils::SourceAnnotationExtractor::Annotation.tags
        tag = (annotations.length > 1)

        Bridgetown::Utils::SourceAnnotationExtractor.enumerate annotations.join("|"), tag: tag, dirs: directories
      end

      protected

      def directories
        Bridgetown::Utils::SourceAnnotationExtractor::Annotation.directories
      end
    end
  end
end
