# frozen_string_literal: true

require "features/feature_helper"

# Render content with ERB and place in Layouts
class TestRubyRendering < BridgetownFeatureTest
  context "ERB" do
    setup do
      create_directory "_layouts"
      create_directory "_posts"
    end

    should "render by default" do
      create_page "_posts/star-wars.md", <<~ERB, title: "Star Wars", date: "2009-03-27", layout: "simple"
        _Luke_, <%= ["I", "am"].join(" ") %> your father.
      ERB

      create_file "_layouts/simple.html", "<h1><%= page.data.title %></h1> <%= yield %>"

      create_configuration template_engine: "erb"

      run_bridgetown "build"

      assert_file_contains "<p><em>Luke</em>, I am your father.</p>", "output/2009/03/27/star-wars/index.html"
      assert_file_contains "<h1>Star Wars</h1>", "output/2009/03/27/star-wars/index.html"
    end

    should "render with Liquid layout" do
      create_page "_posts/star-wars.md", <<~ERB, title: "Star Wars", date: "2009-03-27", layout: "simple"
        _Luke_, <%= ["I", "am"].join(" ") %> your father.
      ERB

      create_file "_layouts/simple.liquid", "<h1>{{ page.title }}</h1> {{ content }}"

      create_configuration template_engine: "erb"

      run_bridgetown "build"

      assert_file_contains "<p><em>Luke</em>, I am your father.</p>", "output/2009/03/27/star-wars/index.html"
      assert_file_contains "<h1>Star Wars</h1>", "output/2009/03/27/star-wars/index.html"
    end

    should "render layout with Liquid resource" do
      create_page "liquidpage.liquid", <<~LIQUID, title: "Star Wars", date: "2009-03-27", layout: "simple"
        Luke, {{ "I,am" | split: "," | join: " " }} your <%= 'father'.upcase %>.
      LIQUID

      create_file "_layouts/simple.html", "<h1><%= page.data.title %></h1> <%= page.data.template_engine %> <%= yield %>"

      create_configuration template_engine: "erb"

      run_bridgetown "build"

      assert_file_contains "Luke, I am your <%= 'father'.upcase %>.", "output/liquidpage/index.html"
      assert_file_contains "<h1>Star Wars</h1>", "output/liquidpage/index.html"
    end

    should "render with Liquid layout via front matter" do
      create_page "_posts/star-wars.md", <<~ERB, title: "Star Wars", date: "2009-03-27", layout: "simple"
        _Luke_, <%= ["I", "am"].join(" ") %> your father.
      ERB

      create_file "_layouts/simple.html", <<~LIQUID
        ---
        template_engine: liquid
        ---
        <h1>{{ page.title }}</h1> {{ content }}
      LIQUID

      create_configuration template_engine: "erb"

      run_bridgetown "build"

      assert_file_contains "<p><em>Luke</em>, I am your father.</p>", "output/2009/03/27/star-wars/index.html"
      assert_file_contains "<h1>Star Wars</h1>", "output/2009/03/27/star-wars/index.html"
    end

    should "render with Liquid but post with template_engine erb" do
      create_page "_posts/star-wars.md", <<~ERB, title: "Star Wars", date: "2009-03-27", layout: "simple", template_engine: "erb"
        _Luke_, <%= ["I", "am"].join(" ") %> your father.
      ERB

      create_file "_layouts/simple.html", <<~LIQUID
        <h1>{{ page.title }}</h1> {{ content }}
      LIQUID

      run_bridgetown "build"

      assert_file_contains "<p><em>Luke</em>, I am your father.</p>", "output/2009/03/27/star-wars/index.html"
      assert_file_contains "<h1>Star Wars</h1>", "output/2009/03/27/star-wars/index.html"
    end

    should "render with custom extension" do
      create_file "data.json", <<~ERB
        ---
        ---
        <%= raw jsonify({key: [1, 1+1, 1+1+1]}) %>
      ERB

      create_configuration template_engine: "erb"

      run_bridgetown "build"

      assert_file_contains '{"key":[1,2,3]}', "output/data.json"
    end

    should "not render when template_engine is none" do
      create_page "_posts/star-wars.md", <<~ERB, title: "Star Wars", date: "2009-03-27", layout: "simple", template_engine: "none"
        _Luke_, <%= ["I", "am"].join(" ") %> your father.
      ERB

      create_file "_layouts/simple.html", "<h1><%= page.data.title %></h1> <%= yield %>"

      create_configuration template_engine: "erb"

      run_bridgetown "build"

      assert_file_contains "<p><em>Luke</em>, &lt;%= [“I”, “am”].join(“ “) %&gt; your father.</p>", "output/2009/03/27/star-wars/index.html"
      assert_file_contains "<h1>Star Wars</h1>", "output/2009/03/27/star-wars/index.html"
    end
  end

  context "pure Ruby" do
    setup do
      create_directory "_posts"
      create_directory "_layouts"
    end

    should "render for .rb files" do
      create_page "_posts/star-wars.rb", <<~RUBY, title: "Star Wars", date: "2009-03-27", layout: "simple"
        luke = "Luke"
        i_am = ["I", "am"].join(" ")
        "\#{luke}, \#{i_am} your father."
      RUBY

      create_file "_layouts/simple.erb", "<h1><%= data.title %></h1> <%= yield %>"

      run_bridgetown "build"

      assert_file_contains "Luke, I am your father.", "output/2009/03/27/star-wars/index.html"
      assert_file_contains "<h1>Star Wars</h1>", "output/2009/03/27/star-wars/index.html"
    end
  end

  context "slotted content" do
    setup do
      create_directory "_layouts"
      create_directory "_posts"
    end

    should "render" do
      create_page "_posts/star-wars.md", <<~ERB, title: "Star Wars", date: "2009-03-27", layout: "simple"
        _Luke_, <%= ["I", "am"].join(" ") %> your father<% slot :subtitle, "V: ", transform: false %><% slot :subtitle, "The Empire Strikes Back", transform: false %>.
      ERB

      create_file "_layouts/simple.html", '<h1><%= page.data.title %> <%= slotted :subtitle, "[BLANK]" %></h1> <%= yield %>'

      create_configuration template_engine: "erb"

      run_bridgetown "build"

      assert_file_contains "<p><em>Luke</em>, I am your father.</p>", "output/2009/03/27/star-wars/index.html"
      assert_file_contains "<h1>Star Wars V: The Empire Strikes Back</h1>", "output/2009/03/27/star-wars/index.html"
    end

    should "show default" do
      create_page "_posts/star-wars.md", <<~ERB, title: "Star Wars", date: "2009-03-27", layout: "simple"
        What a piece of junk!
      ERB

      create_file "_layouts/simple.html", '<h1><%= data.title %>: <%= slotted :subtitle, "[BLANK]" %></h1> <%= yield %>'

      create_configuration template_engine: "erb"

      run_bridgetown "build"

      assert_file_contains "<h1>Star Wars: [BLANK]</h1>", "output/2009/03/27/star-wars/index.html"
    end

    should "replace slot" do
      create_page "_posts/star-wars.md", <<~ERB, title: "Star Wars", date: "2009-03-27", layout: "simple"
        <% slot "title" do %># Star Trek<% end %><% slot "title", replace: true do %> # <%= data.title %><% end %>
      ERB

      create_file "_layouts/simple.html", '<%= slotted :title, "[BLANK]" %> <%= yield %>'

      create_configuration template_engine: "erb"

      run_bridgetown "build"

      assert_file_contains "<h1 id=\"star-wars\">Star Wars</h1>", "output/2009/03/27/star-wars/index.html"
    end
  end
end
