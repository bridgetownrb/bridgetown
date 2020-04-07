require "bridgetown-core/version"

module BridgetownSite
  class CurrentVersionTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @text = text
    end

    def render(context)
      "v#{Bridgetown::VERSION}"
    end
  end
end

Liquid::Template.register_tag('current_bridgetown_version', BridgetownSite::CurrentVersionTag)
