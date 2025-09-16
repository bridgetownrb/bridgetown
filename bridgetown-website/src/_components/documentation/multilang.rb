class Documentation::Multilang < Bridgetown::Component
  def code_blocks
    @code_blocks ||= content.split "==="
  end

  def languages
    @languages ||= code_blocks.map do |example|
      example.match(%r!```([a-z]+)\n!)[1]
    end
  end

  def titles_for_languages
    @titles_for_languages ||= languages.map do |lang|
      case lang
      when "ruby"
        "Ruby"
      when "erb"
        "ERB"
      when "liquid"
        "Liquid"
      when "serb"
        "Serbea"
      when "yaml"
        "YAML (Legacy)"
      else
        "UNKNOWN"
      end
    end
  end

  def template
    html -> { <<~HTML
      <sl-tab-group>
        <sl-tab slot="nav" panel="#{text -> { languages[0] }}">#{text -> { titles_for_languages[0] }}</sl-tab>
        <sl-tab slot="nav" panel="#{text -> { languages[1] }}">#{text -> { titles_for_languages[1] }}</sl-tab>

        <sl-tab-panel name="#{text -> { languages[0] }}" markdown="block">
      #{html -> { code_blocks[0] }}
        </sl-tab-panel>
        <sl-tab-panel name="#{text -> { languages[1] }}" markdown="block">
      #{html -> { code_blocks[1] }}
        </sl-tab-panel>
      </sl-tab-group>
    HTML
    }
  end
end
