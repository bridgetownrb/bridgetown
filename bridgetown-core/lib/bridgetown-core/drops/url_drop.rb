# frozen_string_literal: true

module Bridgetown
  module Drops
    class UrlDrop < Drop
      extend Forwardable

      mutable false

      def_delegator :@obj, :cleaned_relative_path, :path
      def_delegator :@obj, :output_ext, :output_ext

      def collection
        @obj.collection.label
      end

      def name
        Utils.slugify(@obj.basename_without_ext)
      end

      def title
        Utils.slugify(qualified_slug_data, mode: "pretty", cased: true)
      end

      def slug
        Utils.slugify(qualified_slug_data)
      end

      def locale
        locale_data = @obj.data["locale"]
        @obj.site.config["available_locales"].include?(locale_data) ? locale_data : nil
      end
      alias_method :lang, :locale

      def categories
        category_set = Set.new
        Array(@obj.data["categories"]).each do |category|
          category_set << if @obj.site.config["slugify_categories"]
                            Utils.slugify(category.to_s)
                          else
                            category.to_s.downcase
                          end
        end
        category_set.to_a.join("/")
      end

      # CCYY
      def year
        @obj.date.strftime("%Y")
      end

      # MM: 01..12
      def month
        @obj.date.strftime("%m")
      end

      # DD: 01..31
      def day
        @obj.date.strftime("%d")
      end

      # hh: 00..23
      def hour
        @obj.date.strftime("%H")
      end

      # mm: 00..59
      def minute
        @obj.date.strftime("%M")
      end

      # ss: 00..59
      def second
        @obj.date.strftime("%S")
      end

      # D: 1..31
      def i_day
        @obj.date.strftime("%-d")
      end

      # M: 1..12
      def i_month
        @obj.date.strftime("%-m")
      end

      # MMM: Jan..Dec
      def short_month
        @obj.date.strftime("%b")
      end

      # MMMM: January..December
      def long_month
        @obj.date.strftime("%B")
      end

      # YY: 00..99
      def short_year
        @obj.date.strftime("%y")
      end

      # CCYYw, ISO week year
      # may differ from CCYY for the first days of January and last days of December
      def w_year
        @obj.date.strftime("%G")
      end

      # WW: 01..53
      # %W and %U do not comply with ISO 8601-1
      def week
        @obj.date.strftime("%V")
      end

      # d: 1..7 (Monday..Sunday)
      def w_day
        @obj.date.strftime("%u")
      end

      # dd: Mon..Sun
      def short_day
        @obj.date.strftime("%a")
      end

      # ddd: Monday..Sunday
      def long_day
        @obj.date.strftime("%A")
      end

      # DDD: 001..366
      def y_day
        @obj.date.strftime("%j")
      end

      private

      def qualified_slug_data
        slug_data = @obj.data["slug"] || @obj.basename_without_ext
        if @obj.data["locale"]
          slug_data.split(".").reject { |component| component == @obj.data["locale"] }.join(".")
        else
          slug_data
        end
      end

      def fallback_data
        @fallback_data ||= {}
      end
    end
  end
end
