# frozen_string_literal: true

require_all "bridgetown-core/filters"

module Bridgetown
  module Filters
    include URLFilters
    include GroupingFilters
    include DateFilters
    include LocalizationFilters
    include TranslationFilters
    include ConditionHelpers

    # Convert a Markdown string into HTML output
    #
    # @param input [String]
    # @return [String] HTML formatted text
    def markdownify(input)
      @context.registers[:site].find_converter_instance(
        Bridgetown::Converters::Markdown
      ).convert(input.to_s)
    end

    # Convert quotes into smart quotes
    #
    # @param input [String]
    # @return [String] smart-quotified text
    def smartify(input)
      Utils::SmartyPantsConverter.new(@context.registers[:site].config).convert(input.to_s)
    end

    # Slugify a filename or title
    #
    # @param input [String] the filename or title to slugify
    # @param mode [String] how string is slugified
    # @see Utils.slugify
    # @return [String] lowercase URL
    def slugify(input, mode = nil)
      mode = @context.registers[:site].config.slugify_mode if mode.nil?
      Utils.slugify(input, mode:)
    end

    # Titleize a slug or identifier string.
    #
    # @param input [String]
    # @see Utils.titleize_slug for more detail
    # @return [String] transformed string with spaces and capitalized words
    def titleize(input)
      Utils.titleize_slug(input)
    end

    # XML escape a string for use. Replaces any special characters with
    # appropriate HTML entity replacements.
    #
    # @example
    #   xml_escape('foo "bar" <baz>')
    #   # => "foo &quot;bar&quot; &lt;baz&gt;"
    #
    # @param input [String]
    # @return [String]
    def xml_escape(input)
      Utils.xml_escape(input)
    end

    # CGI escape a string for use in a URL. Replaces any special characters
    # with appropriate %XX replacements.
    #
    # @example
    #   cgi_escape('foo,bar;baz?')
    #   # => "foo%2Cbar%3Bbaz%3F"
    #
    # @param input [String]
    # @return [String]
    def cgi_escape(input)
      CGI.escape(input.to_s)
    end

    # URI escape a string.
    #
    # @example
    #   uri_escape('foo, bar \\baz?')
    #   # => "foo,%20bar%20%5Cbaz?"
    #
    # @param input [String]
    # @return [String]
    def uri_escape(input)
      Addressable::URI.normalize_component(input)
    end

    # Obfuscate an email, telephone number etc.
    #
    # @param input[String] the String containing the contact information (email, phone etc.)
    # @param prefix[String] the URL scheme to prefix (default "mailto")
    # @return [String] a link unreadable for bots but will be recovered on focus or mouseover
    def obfuscate_link(input, prefix = "mailto")
      link = "<a href=\"#{prefix}:#{input}\">#{input}</a>"
      script = "<script type=\"text/javascript\">document.currentScript.insertAdjacentHTML('"
      script += "beforebegin', '#{rot47(link).gsub("\\", '\\\\\\')}'.replace(/[!-~]/g," # rubocop:disable Style/StringLiteralsInInterpolation
      script += "function(c){{var j=c.charCodeAt(0);if((j>=33)&&(j<=126)){"
      script += "return String.fromCharCode(33+((j+ 14)%94));}"
      script += "else{return String.fromCharCode(j);}}}));</script>"
      script.html_safe
    end

    # Replace any whitespace in the input string with a single space
    #
    # @param input [String]
    # @return [String]
    def normalize_whitespace(input)
      input.to_s.gsub(%r!\s+!, " ").strip
    end

    # Count the number of words in the input string.
    #
    # @param input [String]
    # @return [Integer] word count
    def number_of_words(input)
      input.split.length
    end

    # Calculates the average reading time of the supplied content
    #
    # @param input [String] the String of content to analyze.
    # @return [Float] the number of minutes required to read the content.
    def reading_time(input, round_to = 0)
      wpm = @context.registers[:site].config[:reading_time_wpm] || 250
      (number_of_words(input).to_f / wpm).ceil(round_to)
    end

    # Join an array of things into a string by separating with commas and the
    # word "and" for the last one
    #
    # @example
    #   array_to_sentence_string(["apples", "oranges", "grapes"])
    #   # => "apples, oranges, and grapes"
    #
    # @param array [Array<String>]
    # @param connector [String] word used to connect the last 2 items in the array
    # @return [String]
    def array_to_sentence_string(array, connector = "and")
      case array.length
      when 0
        ""
      when 1
        array[0].to_s
      when 2
        "#{array[0]} #{connector} #{array[1]}"
      else
        "#{array[0...-1].join(", ")}, #{connector} #{array[-1]}"
      end
    end

    # Convert the input into JSON string
    #
    # @param input [Array, Hash, String, Integer]
    # @return [String] JSON string
    def jsonify(input)
      as_liquid(input).to_json
    end

    # Filter an array of objects or a hash (will use values)
    #
    # @param input [Array, Hash]
    # @param property [String] the property within each object to filter by
    # @param value [String] value for the search
    # @return [Array] filtered array of objects
    def where(input, property, value) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      return input if !property || value.is_a?(Array) || value.is_a?(Hash)
      return input unless input.respond_to?(:select)

      input    = input.values if input.is_a?(Hash)
      input_id = input.hash

      # implement a hash based on method parameters to cache the end-result
      # for given parameters.
      @where_filter_cache ||= {}
      @where_filter_cache[input_id] ||= {}
      @where_filter_cache[input_id][property] ||= {}

      # stash or retrive results to return
      @where_filter_cache[input_id][property][value] ||= input.select do |object|
        compare_property_vs_target(item_property(object, property), value)
      end.to_a
    end

    # Filters an array of objects against an expression
    #
    # @param input [Array, Hash]
    # @param variable [String] the variable to assign each item to in the expression
    # @param expression [String] a Liquid comparison expression passed in as a string
    # @return [Array] filtered array of objects
    def where_exp(input, variable, expression)
      return input unless input.respond_to?(:select)

      input = input.values if input.is_a?(Hash)

      condition = parse_condition(expression)
      @context.stack do
        input.select do |object|
          @context[variable] = object
          condition.evaluate(@context)
        end
      end || []
    end

    # Convert the input into integer
    #
    # @param input [String, Boolean] if boolean, 1 for true and 0 for false
    # @return [Integer]
    def to_integer(input)
      return 1 if input == true
      return 0 if input == false

      input.to_i
    end

    # Sort an array of objects
    #
    # @param input [Array]
    # @param property [String] the property within each object to filter by
    # @param nils [String] `first` | `last` (nils appear before or after non-nil values)
    # @return [Array] sorted array of objects
    def sort(input, property = nil, nils = "first")
      raise ArgumentError, "Cannot sort a null object." if input.nil?

      if property.nil?
        input.sort
      else
        case nils
        when "first"
          order = - 1
        when "last"
          order = + 1
        else
          raise ArgumentError, "Invalid nils order: " \
                               "'#{nils}' is not a valid nils order. It must be 'first' or 'last'."
        end

        sort_input(input, property, order)
      end
    end

    def pop(array, num = 1)
      return array unless array.is_a?(Array)

      num = Liquid::Utils.to_integer(num)
      new_ary = array.dup
      new_ary.pop(num)
      new_ary
    end

    def push(array, input)
      return array unless array.is_a?(Array)

      new_ary = array.dup
      new_ary.push(input)
      new_ary
    end

    def shift(array, num = 1)
      return array unless array.is_a?(Array)

      num = Liquid::Utils.to_integer(num)
      new_ary = array.dup
      new_ary.shift(num)
      new_ary
    end

    def unshift(array, input)
      return array unless array.is_a?(Array)

      new_ary = array.dup
      new_ary.unshift(input)
      new_ary
    end

    def sample(input, num = 1)
      return input unless input.respond_to?(:sample)

      num = Liquid::Utils.to_integer(num) rescue 1
      if num == 1
        input.sample
      else
        input.sample(num)
      end
    end

    # Convert an object into its String representation for debugging
    #
    # @param input [Object] The Object to be converted
    #
    # @return [String] the representation of the object.
    def inspect(input = nil)
      return super() if input.nil?

      xml_escape(input.inspect)
    end

    private

    # Perform a rot47 rotation for obfuscation
    def rot47(input)
      input.tr "!-~", "P-~!-O"
    end

    # Sort the input Enumerable by the given property.
    # If the property doesn't exist, return the sort order respective of
    # which item doesn't have the property.
    # We also utilize the Schwartzian transform to make this more efficient.
    def sort_input(input, property, order) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      input.map { |item| [item_property(item, property), item] }
        .sort! do |a_info, b_info|
          a_property = a_info.first
          b_property = b_info.first

          if !a_property.nil? && b_property.nil?
            - order
          elsif a_property.nil? && !b_property.nil?
            + order
          else
            a_property <=> b_property || a_property.to_s <=> b_property.to_s
          end
        end
        .map!(&:last)
    end

    # `where` filter helper
    #
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def compare_property_vs_target(property, target)
      case target
      when NilClass
        return true if property.nil?
      when "" # aka `empty` or `blank`
        target = target.to_s
        return true if property == target || Array(property).join == target
      else
        target = target.to_s
        if property.is_a? String
          return true if property == target
        else
          Array(property).each do |prop|
            return true if prop.to_s == target
          end
        end
      end

      false
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    def item_property(item, property)
      @item_property_cache ||= {}
      @item_property_cache[property] ||= {}
      @item_property_cache[property][item] ||= begin
        property = property.to_s
        property = if item.respond_to?(:to_liquid)
                     read_liquid_attribute(item.to_liquid, property)
                   elsif item.respond_to?(:data)
                     item.data[property]
                   else
                     item[property]
                   end

        parse_sort_input(property)
      end
    end

    def read_liquid_attribute(liquid_data, property)
      return liquid_data[property] unless property.include?(".")

      property.split(".").reduce(liquid_data) do |data, key|
        data.respond_to?(:[]) && data[key]
      end
    end

    FLOAT_LIKE   = %r!\A\s*-?(?:\d+\.?\d*|\.\d+)\s*\Z!
    INTEGER_LIKE = %r!\A\s*-?\d+\s*\Z!
    private_constant :FLOAT_LIKE, :INTEGER_LIKE

    # return numeric values as numbers for proper sorting
    def parse_sort_input(property)
      stringified = property.to_s
      return property.to_i if INTEGER_LIKE.match?(stringified)
      return property.to_f if FLOAT_LIKE.match?(stringified)

      property
    end

    def as_liquid(item)
      case item
      when Hash
        pairs = item.map { |k, v| as_liquid([k, v]) }
        Hash[pairs] # rubocop:todo Style/HashConversion
      when Array
        item.map { |i| as_liquid(i) }
      else
        if item.respond_to?(:to_liquid)
          liquidated = item.to_liquid
          # prevent infinite recursion for simple types (which return `self`)
          if liquidated == item
            item
          else
            as_liquid(liquidated)
          end
        else
          item
        end
      end
    end
  end
end

Liquid::Template.register_filter(
  Bridgetown::Filters
)
