require "ruby2js/filter/functions"
require "ruby2js/filter/camelCase"
require "ruby2js/filter/return"
require "ruby2js/filter/esm"
require "ruby2js/filter/tagged_templates"

module Ruby2JS
  class Loader
    def self.process(source)
      Ruby2JS.convert(source, eslevel: 2021).to_s
    end
  end
end
