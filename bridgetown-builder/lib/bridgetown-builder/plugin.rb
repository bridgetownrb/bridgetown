# frozen_string_literal: true

module Bridgetown
  module Builders
    class PluginBuilder
      attr_accessor :functions, :name, :site, :config

      def initialize(name, current_site = nil)
        self.functions = Set.new
        self.name = name
        self.site = current_site || Bridgetown.sites.first

        self.config = if defined?(self.class::CONFIG_DEFAULTS)
                        Bridgetown::Utils.deep_merge_hashes(
                          self.class::CONFIG_DEFAULTS, site.config
                        )
                      else
                        site.config
                      end
      end

      def inspect
        "#{name} (Hook)"
      end

      # rubocop:disable Metrics/AbcSize
      def generator(&block)
        custom_name = name
        new_gen = Class.new(Bridgetown::Generator) do
          @generate_block = block
          @custom_name = custom_name

          class << self
            attr_reader :generate_block
            attr_reader :custom_name
          end

          def inspect
            "#{self.class.custom_name} (Generator)"
          end

          def generate(site)
            block = self.class.generate_block
            instance_exec(site, &block)
          end
        end

        first_low_priority_index = site.generators.find_index { |gen| gen.class.priority == :low }
        site.generators.insert(first_low_priority_index, new_gen.new(site.config))

        functions << { name: name, generator: new_gen }
      end
      # rubocop:enable Metrics/AbcSize

      def liquid_filter(filter_name, &block)
        m = Module.new
        m.send(:define_method, filter_name, &block)
        Liquid::Template.register_filter(m)

        functions << { name: name, filter: m }
      end

      def liquid_tag(tag_name, &block)
        custom_name = name
        tag = Class.new(Liquid::Tag) do
          @render_block = block
          @custom_name = custom_name

          class << self
            attr_reader :render_block
            # rubocop:disable Lint/DuplicateMethods
            attr_reader :custom_name
            # rubocop:enable Lint/DuplicateMethods
          end

          def inspect
            "#{self.class.custom_name} (Liquid Tag)"
          end

          def render(context)
            block = self.class.render_block
            instance_exec(
              @markup.strip, context.registers[:site], context.registers[:page], &block
            )
          end
        end

        Liquid::Template.register_tag tag_name, tag
        functions << { name: name, tag: [tag_name, tag] }
      end

      def hook(owner, event, priority: Bridgetown::Hooks::DEFAULT_PRIORITY, &block)
        hook_block = Bridgetown::Hooks.register_one(owner, event, priority: priority, &block)
        functions << { name: name, hook: [owner, event, priority, hook_block] }
      end

      def add_data(data_key)
        hook(:site, :post_read) do |site|
          site.data[data_key] = yield(site).with_indifferent_access
        end
      end

      def doc(path, &block)
        VirtualGenerator.add(path, block)
      end

      def get(url)
        body = connection.get(url).body
        data = JSON.parse(body, symbolize_names: true) rescue nil
        yield data || body
      end

      def connection
        Faraday.new(headers: { "Content-Type" => "application/json" })
      end
    end
  end
end
