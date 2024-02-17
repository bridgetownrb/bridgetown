---
title: Front Matter Loaders
order: 0
top_section: Configuration
category: plugins
---

This API allows you or a third-party gem to augment resources with new types of front matter. To do so, create a new class inheriting from `Bridgetown::FrontMatter::Loaders::Base` that defines an override of the `#read` method, then register it using `Bridgetown::FrontMatter::Loaders.register`.

Typically, loaders define two constants by convention:

1. `HEADER` matches the opening line of the front matter
2. `BLOCK` matches the contents of the front matter block with the first capturing group being the content and the regular expression consuming the ending delimiter

The `#read` method returns a nullable `Bridgetown::FrontMatter::Loaders::Result` with these three attributes:

1. `content` - the content of the resource without the front matter
2. `front_matter` - the front matter hash after processing the front matter content
3. `line_count` - the number of lines making up the front matter content

## Limitations

Currently, front matter loaders process the contents of resources in First-In, First-Out (FIFO) order meaning the built-in loaders take precedence over any new ones.

This means that loaders should not have overlapping delimiter definitions. Because Bridgetown is flexible in its delimiters — e.g. the YAML loader accepts triple- hyphens, tildes, backticks, or pounds for its code blocks — you must take care when picking delimiters so that multiple loaders do not overlap definitions.
