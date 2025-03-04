class Documentation::Multilang < Bridgetown::Component
  def template
    split_content = content.split("===")

    html -> { <<~HTML
      <sl-tab-group>
        <sl-tab slot="nav" panel="erb">ERB</sl-tab>
        <sl-tab slot="nav" panel="liquid">Liquid</sl-tab>

        <sl-tab-panel name="erb" markdown="block">
      #{html -> { split_content[0] }}
        </sl-tab-panel>
        <sl-tab-panel name="liquid" markdown="block">
      #{html -> { split_content[1] }}
        </sl-tab-panel>
      </sl-tab-group>
    HTML
    }
  end
end
