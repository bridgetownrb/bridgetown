class Documentation::Multilang < Bridgetown::Component
  def template
    split_content = content.split("===")
    languages = split_content.map do |example|
      example.match(%r!```([a-z]+)\n!)[1]
    end
    puts languages
    language_titles = languages.map do |lang|
      case lang
      when "erb"
        "ERB"
      when "liquid"
        "Liquid"
      when "serb"
        "Serbea"
      else
        "UNKNOWN"
      end
    end

    html -> { <<~HTML
      <sl-tab-group>
        <sl-tab slot="nav" panel="#{text -> { languages[0] }}">#{text -> { language_titles[0] }}</sl-tab>
        <sl-tab slot="nav" panel="#{text -> { languages[1] }}">#{text -> { language_titles[1] }}</sl-tab>

        <sl-tab-panel name="#{text -> { languages[0] }}" markdown="block">
      #{html -> { split_content[0] }}
        </sl-tab-panel>
        <sl-tab-panel name="#{text -> { languages[1] }}" markdown="block">
      #{html -> { split_content[1] }}
        </sl-tab-panel>
      </sl-tab-group>
    HTML
    }
  end
end
