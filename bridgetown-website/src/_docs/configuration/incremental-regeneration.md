---
title: Default Configuration
hide_in_toc: true
order: 0
category: configuration
---

## Incremental Regeneration

Incremental regeneration helps shorten build times by only generating documents
and pages that were updated since the previous build. It does this by keeping
track of both file modification times and inter-document dependencies in the
`.bridgetown-metadata` file.

Under the current implementation, incremental regeneration will only generate a
document or page if either it, or one of its dependencies, is modified. Currently,
the only types of dependencies tracked are includes (using the
{% raw %}`{% include %}`{% endraw %} tag) and layouts. This means that plain
references to other documents (for example, the common case of iterating over
`site.posts` in a post listings page) will not be detected as a dependency.

To remedy some of these shortfalls, putting `regenerate: true` in the front-matter
of a document will force Bridgetown to regenerate it regardless of whether it has been
modified. Note that this will generate the specified document only; references
to other documents' contents will not work since they won't be re-rendered.

Incremental regeneration can be enabled via the `--incremental` flag (`-I` for
short) from the command-line or by setting `incremental: true` in your
configuration file.

{% rendercontent "docs/note", title: "Incremental regeneration is an advanced feature", type: "warning", extra_margin: true %}
  While incremental regeneration will work for the most common cases, it will
  not work correctly in every scenario. Please report any problems not listed above by
  <a href="https://github.com/bridgetownrb/bridgetown/issues/new" rel="noopener">opening an issue on GitHub</a>.
{% endrendercontent %}
