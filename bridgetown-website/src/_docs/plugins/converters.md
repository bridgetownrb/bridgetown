---
title: Converters
order: 0
top_section: Configuration
category: plugins
---

If you have a new markup or template language you’d like to use with your site,
you can process it by implementing your own converter. The Markdown and ERB
support in Bridgetown is implemented using this very method.

{%@ Note do %}
  #### Remember your Front Matter

  Bridgetown will only convert files that have a YAML or Ruby Front Matter header at the top, even for converters you add using a plugin.
{% end %}

Below is a converter which will take all posts ending in `.upcase` and process
them using the `UpcaseConverter`:

```ruby
# ./plugins/upcase_converter.rb

class UpcaseConverter < Bridgetown::Converter
  priority :low

  input :upcase

  def convert(content)
    content.upcase
  end
end
```

In this example, the `convert` method is provided the raw content of the file
(without front matter), and it returns an uppercase string back. The converter
will only run for files with the extension(s) defined using the `input` class
method.

If you need to examine the source page/document or layout object which is
responsible for processing the file, you can access it using a second `convertible`
argument:

```ruby
def convert(content, convertible)
  content + " — brought to you by the #{convertible.class} object."
end
```