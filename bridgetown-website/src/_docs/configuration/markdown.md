---
title: Markdown Options
order: 0
top_section: Configuration
category: customize-your-site
back_to: configuration
---

### Kramdown

Kramdown is the Markdown renderer for Bridgetown. Below is a list of the
currently supported options:

* **auto_id_prefix** - Prefix used for automatically generated header IDs
* **auto_id_stripping** - Strip all formatting from header text for automatic ID generation
* **auto_ids** - Use automatic header ID generation
* **entity_output** - Defines how entities are output
* **footnote_backlink** - Defines the text that should be used for the footnote backlinks
* **footnote_backlink_inline** - Specifies whether the footnote backlink should always be inline
* **footnote_nr** - The number of the first footnote
* **gfm_quirks** - Enables a set of GFM specific quirks
* **hard_wrap** - Interprets line breaks literally
* **header_offset** - Sets the output offset for headers
* **html_to_native** - Convert HTML elements to native elements
* **line_width** - Defines the line width to be used when outputting a document
* **link_defs** - Pre-defines link definitions
* **mark_highlighting** - When `true`, allows `==text==` or `::text::` to highlight text with `<mark>` tags (this is a custom Bridgetown-only option)
* **math_engine** - Set the math engine
* **math_engine_opts** - Set the math engine options
* **parse_block_html** - Process kramdown syntax in block HTML tags
* **parse_span_html** - Process kramdown syntax in span HTML tags
* **smart_quotes** - Defines the HTML entity names or code points for smart quote output
* **syntax_highlighter** - Set the syntax highlighter
* **syntax_highlighter_opts** - Set the syntax highlighter options
* **toc_levels** - Defines the levels that are used for the table of contents
* **transliterated_header_ids** - Transliterate the header text before generating the ID
* **typographic_symbols** - Defines a mapping from typographical symbol to output characters

For more details about these options have a look at the [Kramdown configuration documentation](https://kramdown.gettalong.org/options.html).

### Custom Markdown Processors

If you're interested in creating a custom markdown processor, you're in luck! Create a new class in the `Bridgetown::Converters::Markdown` namespace:

```ruby
class Bridgetown::Converters::Markdown::MyCustomProcessor
  def initialize(config)
    require 'funky_markdown'
    @config = config
  rescue LoadError
    STDERR.puts 'You are missing a library required for Markdown. Please run:'
    STDERR.puts '  $ [sudo] gem install funky_markdown'
    raise FatalException.new("Missing dependency: funky_markdown")
  end

  def convert(content)
    ::FunkyMarkdown.new(content).convert
  end
end
```

Once you've created your class and have it properly set up either as a plugin
in the `plugins` folder or as a gem, specify it in your `bridgetown.config.yml`:

```yaml
markdown: MyCustomProcessor
```
