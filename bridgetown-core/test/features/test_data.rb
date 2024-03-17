# frozen_string_literal: true

require "features/feature_helper"

# I want to use _data directory in my site
class TestData < BridgetownFeatureTest
  context "autoloading data" do
    setup do
      create_directory "_data"
    end

    should "support *.yaml" do
      create_file "_data/products.yaml", <<~YAML
        - name: sugar
          price: 5.3
        - name: salt
          price: 2.5
      YAML

      create_page "index.html", "{% for product in site.data.products %}{{product.name}}{% endfor %}", title: "Simple Test"

      run_bridgetown "build"

      assert_file_contains "sugar", "output/index.html"
      assert_file_contains "salt", "output/index.html"
    end

    should "support *.yml" do
      create_file "_data/members.yml", <<~YAML
        - name: Jack
          age: 28
        - name: Leon
          age: 34
      YAML

      create_page "index.html", "{% for member in site.data.members %}{{member.name}}{% endfor %}", title: "Simple Test"

      run_bridgetown "build"

      assert_file_contains "Jack", "output/index.html"
      assert_file_contains "Leon", "output/index.html"
    end

    should "support *.json" do
      create_file "_data/members.json", <<~JSON
        [{"name": "Jack", "age": 28},{"name": "Leon", "age": 34}]
      JSON

      create_page "index.html", "{% for member in site.data.members %}{{member.name}}{% endfor %}", title: "Simple Test"

      run_bridgetown "build"

      assert_file_contains "Jack", "output/index.html"
      assert_file_contains "Leon", "output/index.html"
    end

    should "support *.csv" do
      create_file "_data/members.csv", <<~CSV
        name,age
        Jack,28
        Leon,34
      CSV

      create_page "index.html", "{% for member in site.data.members %}{{member.name}}{% endfor %}", title: "Simple Test"

      run_bridgetown "build"

      assert_file_contains "Jack", "output/index.html"
      assert_file_contains "Leon", "output/index.html"
    end

    should "support *.tsv" do
      create_file "_data/members.tsv", <<~TSV
        name	age
        Ingrid	28
        Gertrude	34
      TSV

      create_page "index.html", "{% for member in site.data.members %}{{member.name}}{% endfor %}", title: "Simple Test"

      run_bridgetown "build"

      assert_file_contains "Ingrid", "output/index.html"
      assert_file_contains "Gertrude", "output/index.html"
    end

    should "support *.yml with space in name" do
      create_file "_data/team members.yml", <<~YAML
        - name: Jack
          age: 28
        - name: Leon
          age: 34
      YAML

      create_page "index.html", "{% for member in site.data.team_members %}{{member.name}}{% endfor %}", title: "Simple Test"

      run_bridgetown "build"

      assert_file_contains "Jack", "output/index.html"
      assert_file_contains "Leon", "output/index.html"
    end

    should "support *.yml inside of a subdirectory, overwriting similarly-named key in parent file" do
      create_directory "_data/categories"
      create_file "_data/categories/dairy.yml", <<~YAML
        name: Dairy Products
      YAML
      create_file "_data/categories.yml", <<~YAML
        dairy:
          name: Should not display this
        produce:
          name: Produce Products
      YAML

      create_page "index.html", "{{ site.data.categories.dairy.name }} {{ site.data.categories.produce.name }}", title: "Simple Test"

      run_bridgetown "build"

      refute_file_contains "Should not display this", "output/index.html"
      assert_file_contains "Dairy Products", "output/index.html"
      assert_file_contains "Produce Products", "output/index.html"
    end
  end
end
