# frozen_string_literal: true

require "helper"

class TestUtils < BridgetownUnitTest
  describe "The `Utils.deep_merge_hashes` method" do
    before do
      clear_dest
      @site = fixture_site
      @site.process
    end

    it "merges a drop into a hash" do
      data = { "page" => {} }
      merged = Utils.deep_merge_hashes(data, @site.site_payload)
      assert merged.is_a? Hash
      assert merged["site"].is_a? Drops::SiteDrop
      assert_equal data["page"], merged["page"]
    end

    it "merges a hash into a drop" do
      data = { "page" => {} }
      assert_nil @site.site_payload["page"]
      merged = Utils.deep_merge_hashes(@site.site_payload, data)
      assert merged.is_a? Drops::UnifiedPayloadDrop
      assert merged["site"].is_a? Drops::SiteDrop
      assert_equal data["page"], merged["page"]
    end
  end

  describe "hash" do
    describe "pluralized_array" do
      it "returns empty array with no values" do
        data = {}
        assert_equal [], Utils.pluralized_array_from_hash(data, "tag", "tags")
      end

      it "returns empty array with no matching values" do
        data = { "foo" => "bar" }
        assert_equal [], Utils.pluralized_array_from_hash(data, "tag", "tags")
      end

      it "returns plural array with nil singular" do
        data = { "foo" => "bar", "tag" => nil, "tags" => %w(dog cat) }
        assert_equal %w(dog cat), Utils.pluralized_array_from_hash(data, "tag", "tags")
      end

      it "returns plural array with merged singular" do
        data = { "foo" => "bar", "tag" => "dog", "tags" => %w(dog cat) }
        assert_equal %w[dog cat], Utils.pluralized_array_from_hash(data, "tag", "tags")
      end

      it "returns array with singular added to pluaral with spaces" do
        data = { "foo" => "bar", "tag" => "dog cat", "tags" => %w(dog cat) }
        assert_equal ["dog cat", "dog", "cat"], Utils.pluralized_array_from_hash(data, "tag", "tags")
      end

      it "returns empty array with matching nil plural" do
        data = { "foo" => "bar", "tags" => nil }
        assert_equal [], Utils.pluralized_array_from_hash(data, "tag", "tags")
      end

      it "returns empty array with matching empty array" do
        data = { "foo" => "bar", "tags" => [] }
        assert_equal [], Utils.pluralized_array_from_hash(data, "tag", "tags")
      end

      it "returns single value array with matching plural with single string value" do
        data = { "foo" => "bar", "tags" => "dog" }
        assert_equal ["dog"], Utils.pluralized_array_from_hash(data, "tag", "tags")
      end

      it "returns multiple value array with matching plural with " \
         "single string value with spaces" do
        data = { "foo" => "bar", "tags" => "dog cat" }
        assert_equal %w(dog cat), Utils.pluralized_array_from_hash(data, "tag", "tags")
      end

      it "returns single value array with matching plural with single value array" do
        data = { "foo" => "bar", "tags" => ["dog"] }
        assert_equal ["dog"], Utils.pluralized_array_from_hash(data, "tag", "tags")
      end

      it "returns multiple value array with matching plural with " \
         "multiple value array" do
        data = { "foo" => "bar", "tags" => %w(dog cat) }
        assert_equal %w(dog cat), Utils.pluralized_array_from_hash(data, "tag", "tags")
      end
    end
  end

  describe "The `Utils.parse_date` method" do
    it "parses a properly formatted date" do
      assert Utils.parse_date("2014-08-02 14:43:06 PDT").is_a? Time
    end

    it "throws an error if the input contains no date data" do
      assert_raises Bridgetown::Errors::InvalidDateError do
        Utils.parse_date("Blah")
      end
    end

    it "throws an error if the input is out of range" do
      assert_raises Bridgetown::Errors::InvalidDateError do
        Utils.parse_date("9999-99-99")
      end
    end

    it "throws an error with the default message if no message is passed in" do
      date = "Blah this is invalid"
      assert_raises(
        Bridgetown::Errors::InvalidDateError,
        "Invalid date '#{date}': Input could not be parsed."
      ) do
        Utils.parse_date(date)
      end
    end

    it "throws an error with the provided message if a message is passed in" do
      date = "Blah this is invalid"
      message = "Aaaah, the world has exploded!"
      assert_raises(
        Bridgetown::Errors::InvalidDateError,
        "Invalid date '#{date}': #{message}"
      ) do
        Utils.parse_date(date, message)
      end
    end
  end

  describe "The `Utils.slugify` method" do
    it "returns nil if passed nil" do
      assert Utils.slugify(nil).nil?
    rescue NoMethodError
      assert false, "Threw NoMethodError"
    end

    it "replaces whitespace with hyphens" do
      assert_equal "working-with-drafts", Utils.slugify("Working with drafts")
    end

    it "replaces consecutive whitespace with a single hyphen" do
      assert_equal "basic-usage", Utils.slugify("Basic   Usage")
    end

    it "trims leading and trailing whitespace" do
      assert_equal "working-with-drafts", Utils.slugify("  Working with drafts   ")
    end

    it "drops trailing punctuation" do
      assert_equal(
        "so-what-is-bridgetown-exactly",
        Utils.slugify("So what is Bridgetown, exactly?")
      )
      assert_equal "كيف-حالك", Utils.slugify("كيف حالك؟")
    end

    it "ignores hyphens" do
      assert_equal "pre-releases", Utils.slugify("Pre-releases")
    end

    it "replaces underscores with hyphens" do
      assert_equal "the-config-yml-file", Utils.slugify("The _config.yml file")
    end

    it "combines adjacent hyphens and spaces" do
      assert_equal(
        "customizing-git-git-hooks",
        Utils.slugify("Customizing Git - Git Hooks")
      )
    end

    it "replaces punctuation in any scripts by hyphens" do
      assert_equal "5時-6時-三-一四", Utils.slugify("5時〜6時 三・一四")
    end

    it "does not replace Unicode 'Mark', 'Letter', or 'Number: Decimal Digit' category characters" do
      assert_equal "மல்லிப்பூ-வகைகள்", Utils.slugify("மல்லிப்பூ வகைகள்")
      assert_equal "மல்லிப்பூ-வகைகள்", Utils.slugify("மல்லிப்பூ வகைகள்", mode: "pretty")
    end

    it "does not modify the original string" do
      title = "Quick-start guide"
      Utils.slugify(title)
      assert_equal "Quick-start guide", title
    end

    it "does not change behaviour if mode is default" do
      assert_equal(
        "the-config-yml-file",
        Utils.slugify("The _config.yml file?", mode: "default")
      )
    end

    it "does not change behaviour if mode is nil" do
      assert_equal "the-config-yml-file", Utils.slugify("The _config.yml file?")
    end

    it "does not replace period and underscore if mode is pretty" do
      assert_equal(
        "the-_config.yml-file",
        Utils.slugify("The _config.yml file?", mode: "pretty")
      )
    end

    it "replaces everything else but ASCII characters" do
      assert_equal "the-config-yml-file",
                   Utils.slugify("The _config.yml file?", mode: "ascii")
      assert_equal "f-rtive-glance",
                   Utils.slugify("fürtive glance!!!!", mode: "ascii")
    end

    it "maps accented latin characters to ASCII characters" do
      assert_equal "the-config-yml-file",
                   Utils.slugify("The _config.yml file?", mode: "latin")
      assert_equal "furtive-glance",
                   Utils.slugify("fürtive glance!!!!", mode: "latin")
      assert_equal "aaceeiioouu",
                   Utils.slugify("àáçèéíïòóúü", mode: "latin")
      assert_equal "a-z",
                   Utils.slugify("Aあわれ鬱господинZ", mode: "latin")
    end

    it "only replaces whitespace if mode is raw" do
      assert_equal(
        "the-_config.yml-file?",
        Utils.slugify("The _config.yml file?", mode: "raw")
      )
    end

    it "returns the given string if mode is none" do
      assert_equal(
        "the _config.yml file?",
        Utils.slugify("The _config.yml file?", mode: "none")
      )
    end

    it "keeps all uppercase letters if cased is true" do
      assert_equal(
        "Working-with-drafts",
        Utils.slugify("Working with drafts", cased: true)
      )
      assert_equal(
        "Basic-Usage",
        Utils.slugify("Basic   Usage", cased: true)
      )
      assert_equal(
        "Working-with-drafts",
        Utils.slugify("  Working with drafts   ", cased: true)
      )
      assert_equal(
        "So-what-is-Bridgetown-exactly",
        Utils.slugify("So what is Bridgetown, exactly?", cased: true)
      )
      assert_equal(
        "Pre-releases",
        Utils.slugify("Pre-releases", cased: true)
      )
      assert_equal(
        "The-config-yml-file",
        Utils.slugify("The _config.yml file", cased: true)
      )
      assert_equal(
        "Customizing-Git-Git-Hooks",
        Utils.slugify("Customizing Git - Git Hooks", cased: true)
      )
      assert_equal(
        "The-config-yml-file",
        Utils.slugify("The _config.yml file?", mode: "default", cased: true)
      )
      assert_equal(
        "The-config-yml-file",
        Utils.slugify("The _config.yml file?", cased: true)
      )
      assert_equal(
        "The-_config.yml-file",
        Utils.slugify("The _config.yml file?", mode: "pretty", cased: true)
      )
      assert_equal(
        "The-_config.yml-file?",
        Utils.slugify("The _config.yml file?", mode: "raw", cased: true)
      )
      assert_equal(
        "The _config.yml file?",
        Utils.slugify("The _config.yml file?", mode: "none", cased: true)
      )
    end

    it "does not include emoji characters" do
      assert_equal "", Utils.slugify("💎")
    end
  end

  describe "The `Utils.titleize_slug` method" do
    it "capitalizes all words and does not drop any words" do
      assert_equal(
        "This Is A Long Title With Mixed Capitalization",
        Utils.titleize_slug("This-is-a-Long-title-with-Mixed-capitalization")
      )
      assert_equal(
        "This Is A Title With Just The Initial Word Capitalized",
        Utils.titleize_slug("This-is-a-title-with-just-the-initial-word-capitalized")
      )
      assert_equal(
        "This Is A Title With No Capitalization",
        Utils.titleize_slug("this-is-a-title-with-no-capitalization")
      )
    end
  end

  describe "The `Utils.safe_glob` method" do
    it "does not apply pattern to the dir" do
      dir = "test/safe_glob_test["
      assert_equal [], Dir.glob("#{dir}/*")
      assert_equal ["test/safe_glob_test[/find_me.txt"], Utils.safe_glob(dir, "*")
    end

    it "returns the same data to #glob" do
      dir = "test"
      assert_equal Dir.glob("#{dir}/*"), Utils.safe_glob(dir, "*")
      assert_equal Dir.glob("#{dir}/**/*"), Utils.safe_glob(dir, "**/*")
    end

    it "returns the same data to #glob if dir is not found" do
      dir = "dir_not_exist"
      assert_equal [], Utils.safe_glob(dir, "*")
      assert_equal Dir.glob("#{dir}/*"), Utils.safe_glob(dir, "*")
    end

    it "returns the same data to #glob if pattern is blank" do
      dir = "test"
      assert_equal [dir], Utils.safe_glob(dir, "")
      assert_equal Dir.glob(dir), Utils.safe_glob(dir, "")
      assert_equal Dir.glob(dir), Utils.safe_glob(dir, nil)
    end

    it "returns the same data to #glob if flag is given" do
      dir = "test"
      assert_equal Dir.glob("#{dir}/*", File::FNM_DOTMATCH),
                   Utils.safe_glob(dir, "*", File::FNM_DOTMATCH)
    end

    it "supports pattern as an array to support windows" do
      dir = "test"
      assert_equal Dir.glob("#{dir}/**/*"), Utils.safe_glob(dir, ["**", "*"])
    end
  end

  describe "The `Utils.has_yaml_header?` method" do
    it "outputs a deprecation message" do
      file = source_dir("_posts", "2008-10-18-foo-bar.markdown")

      output = capture_output do
        Utils.has_yaml_header?(file)
      end

      assert_match ".has_yaml_header? is deprecated", output
    end
  end

  describe "The `Utils.has_rbfm_header?` method" do
    it "outputs a deprecation message" do
      file = source_dir("_posts", "2008-10-18-foo-bar.markdown")

      output = capture_output do
        Utils.has_rbfm_header?(file)
      end

      assert_match ".has_rbfm_header? is deprecated", output
    end
  end

  describe "The `Utils.merged_file_read_opts` method" do
    it "ignores encoding if it's not there" do
      opts = Utils.merged_file_read_opts(nil, {})
      assert_nil opts["encoding"]
      assert_nil opts[:encoding]
    end

    it "adds bom to encoding" do
      opts = { "encoding" => "utf-8", :encoding => "utf-8" }
      merged = Utils.merged_file_read_opts(nil, opts)
      assert_equal "bom|utf-8", merged["encoding"]
      assert_equal "bom|utf-8", merged[:encoding]
    end

    it "preserves bom in encoding" do
      opts = { "encoding" => "bom|another", :encoding => "bom|another" }
      merged = Utils.merged_file_read_opts(nil, opts)
      assert_equal "bom|another", merged["encoding"]
      assert_equal "bom|another", merged[:encoding]
    end
  end

  describe "The `Utils.default_github_branch_name` method" do
    it "returns the correct default branch name" do
      Faraday.stub :get, HashWithDotAccess::Hash.new(body: JSON.generate({ "default_branch" => "my_default_branch" })) do
        assert_equal "my_default_branch", Utils.default_github_branch_name("https://github.com/whitefusionhq/phaedra/abc/12344")
      end
    end

    it "returns main if all else fails" do
      Faraday.stub :get, proc { raise("nope") } do
        assert_equal "main", Utils.default_github_branch_name("https://github.com/thisorgdoesntexist/thisrepoistotallybogus")
      end
    end
  end

  describe "The `Utils.helper_code_for_template_extname` method" do
    it "returns content within delimiters for the supplied file extname" do
      assert_equal "{% content %}", Utils.helper_code_for_template_extname(".liquid", "content")
      assert_equal "<%= content %>", Utils.helper_code_for_template_extname(".erb", "content")
    end

    it "raises an error if the supplied extname is not supported" do
      assert_raises do
        Utils.helper_code_for_template_extname(".not_a_template_engine", "content")
      end
    end
  end
end
