# frozen_string_literal: true

module Bridgetown
  module Builders
    module DSL
      module Resources
        def resource
          @resource # could be nil
        end

        def add_resource(collection_name, path, &block) # rubocop:todo Metrics/AbcSize
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

        def define_resource_method(method_name, class_scope: false, &block)
          unless block
            builder_self = self
            block = proc do |*args, **kwargs, &block2|
              prev_var = builder_self.instance_variable_get(:@resource)
              builder_self.instance_variable_set(:@resource, self)
              builder_self.send(method_name, *args, **kwargs, &block2).tap do
                builder_self.instance_variable_set(:@resource, prev_var)
              end
            end
          end

          m = Module.new
          m.define_method method_name, &block

          class_scope ? Bridgetown::Resource::Base.extend(m) : Bridgetown::Resource::Base.include(m)
        end

        def permalink_placeholder(key, &block)
          Bridgetown::Resource::PermalinkProcessor.register_placeholder(
            key, block
          )
        end

        def placeholder_processors
          Bridgetown::Resource::PermalinkProcessor.placeholder_processors
        end
      end
    end
  end
end
