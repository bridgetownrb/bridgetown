# frozen_string_literal: true

module TestingResourceExtension
  def self.return_string
    "return value"
  end

  module LiquidResource
    def heres_a_liquid_method
      "Liquid #{TestingResourceExtension.return_string}"
    end
  end

  module RubyResource
    def heres_a_method(arg = nil)
      "Ruby #{TestingResourceExtension.return_string}! #{arg}"
    end
  end
end

Bridgetown::Resource.register_extension TestingResourceExtension

module TestingSummaryService
  module RubyResource
    def summary_extension_output
      "SUMMARY! #{content.strip[0..10]} DONE"
    end
  end
end
