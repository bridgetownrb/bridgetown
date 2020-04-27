require "bridgetown-core/version"

module BridgetownSite
  class CurrentVersionTag < Liquid::Tag
    def render(context)
      "v#{Bridgetown::VERSION}"
    end
  end

  class CurrentCodeNameTag < Liquid::Tag
    def render(context)
      "#{Bridgetown::CODE_NAME}"
    end
  end
end

Liquid::Template.register_tag('current_bridgetown_version', BridgetownSite::CurrentVersionTag)

Liquid::Template.register_tag('current_bridgetown_code_name', BridgetownSite::CurrentCodeNameTag)