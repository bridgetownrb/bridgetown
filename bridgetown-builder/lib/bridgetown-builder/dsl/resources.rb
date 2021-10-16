# frozen_string_literal: true

module Bridgetown
  module Builders
    module DSL
      module Resources
        def add_resource(collection_name, path, &block)
          data = Bridgetown::Utils::RubyFrontMatter.new(scope: self).tap do |fm|
            fm.define_singleton_method(:___) do |hsh|
              hsh.each do |k, v|
                fm.set k, v
              end
            end
            fm.instance_exec(&block)
          end.to_h
          if data[:content]
            data[:_content_] = data[:content]
            data.delete :content
          end

          collection_name = collection_name.to_s
          unless @site.collections[collection_name]
            Bridgetown.logger.info(
              "#{self.class.name}:",
              "Creating `#{collection_name}' collection on the fly..."
            )
            collection = Collection.new(@site, collection_name)
            collection.metadata["output"] = true
            @site.collections[collection_name] = collection
          end

          Bridgetown::Model::Base.build(
            self,
            collection_name,
            path,
            data
          ).as_resource_in_collection
        end
      end
    end
  end
end
