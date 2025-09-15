---
title: Foundation Gem
order: 0
top_section: Configuration
category: plugins
---

The Foundation gem is part of the Bridgetown Ruby API, offering some handy helpers for strings, hashes, class hierarchies, and more. Over time we intend to migrate reusable, utility-like patterns elsewhere in the Bridgetown codebase to this Foundation gem. We hope this can prove useful even on non-Bridgetown projects (you could `bundle add bridgetown-foundation` directly).

A number of the features in Foundation are provided via a Ruby feature called [refinements](https://docs.ruby-lang.org/en/master/syntax/refinements_rdoc.html). This may not be so well-known to some developers, so we'll explain how it works.

{{ toc }}

## How Refinements Work (and How to Add Your Own)

A refinement is like a mixin for an existing Ruby class, but instead of monkey-patching that class in a global way, it only patches within a lexical scope. When you activate a refinement via `using`, you have access to that refinement only within that scope (which could be a module or class, or an entire Ruby file).

The Foundation refinements are all bundled together within a single module, so to "opt-in" with your code, call `using Bridgetown::Refinements`.

Here's an example:

```ruby
using Bridgetown::Refinements

"abc".within? %w[xyz abc] # true
```

The `within?` method is only available in a scope where the refinements are activated. Here's an example of scoping to a single class:

```ruby
class TryWithin
  using Bridgetown::Refinements

  def initialize(str) = @str = str
  def is_within?(arr) = @str.within? arr
end

TryWithin.new("abc").is_within?(%w[xyz abc]) # true

"abc".within? %w[xyz abc] # raises NoMethodError
```

There are certain contexts in which it's not possible use `using`, for example in Roda server blocks or Ruby templates like `.erb`. In those cases, you can "refine an object" directly with the `refine` helper and use refinement methods on that:

```ruby
refine("abc").within? %w[xyz abc] # true
```

There's also a `Bridgetown.refine(obj)` method you can call if the helper is not available in a certain execution context. Otherwise, you can write `include Bridgetown::Refinements::Helper`—but most likely, if you're in a position to do that you can simply go with the normal `using` way of activating refinements.

Under the hood, a "refined object" is a `SimpleDelegator` Ruby class which wraps the original object, so using the refined object is indistinguishable from using the original object (other than refinement methods are available).

**Foundation makes it easy to add your own refinements!** There's only a small amount of boilerplate required:

```ruby
module Adding
  refine Numeric do
    def add(input)
      self + input
    end
  end
end

Bridgetown.add_refinement(Adding) do
  # This is required boilerplate:
  using Bridgetown::Refinements
  def method_missing(...) = __getobj__.send(...) # rubocop:disable Style
end
```

and then:

```ruby
class AddNumbers
  using Bridgetown::Refinements

  def initialize(num) = @num = num
  def together(new_num) = @num.add new_num
end

AddNumbers.new(10).together(15) # 25
```

You could put this in a config file or in a plugin gem, whatever makes sense for your use case.

## Foundation API

The following methods are accessed via refinements unless otherwise noted.

### Object

#### `within?`

This method lets you check if the receiver is "within" the other object. In most cases, this check is accomplished via the `include?` method…aka, `10.within? [5, 10]` would return `true` as `[5, 10].include? 10` is true. String/String comparison are case-insensitive, so `"FOO".within?("foobar")` is true.

However, for certain comparison types: Module/Class, Hash, and Set, the lesser-than (`<`) operator is used instead. This is so you can check `BigDecimal.within? Numeric`, `{easy_as: 123}.within?({indeed: "it's true", easy_as: 123})`, and `Set[:b, :c].within? Set[:a, :b, :c, :d]` (under the hood Set evaluates using `proper_subset?`).

For Array/Array comparisons, a difference (`&&`) is checked, so `[1,2].within? [3,2,1]` is true, but `[1,2].within? [2,3]` is false.

For Range, the `cover?` method is used, so `(3..4).within?(2..6)` is true, but `(1..4).within?(2..6)` is false.

### Class

#### `descendants`

**Monkey-patch.** This class method lets you retrieve a flattened array of all of a class' descendants (and their descendants if applicable, etc.). There are two stipulations for a class to be included: it has to have a name (so no anonymous classes), and it has to be available in the global namespace (aka accessible via `Kernel.const_get`).

### String

#### `indent` / `indent!`

This lets you indent a string by a certain number of spaces. `"it\n  is indented\n\nnow".indent(2)` would result in `"  it\n    is indented\n\n  now"` (each line now starts with two spaces). `indent!` modifies a string in-place.

#### `starts_with?` / `ends_with?`

**Monkey-patch.** Aliases for Ruby's native `start_with?` and `end_with?` methods.

#### `questionable?`

This returns a `Bridgetown::Foundation::QuestionableString` copy of the string, now with the ability to use a question method. `"test".questionable.test?` will return true, whereas `"test".questionable.nope?` will return false. This is used by `Bridgetown.env` so you can call `Bridgetown.env.production?`.

#### colors (`red`, `cyan`, etc.)

**Monkey-patch.** You can use ANSI color methods on strings as part of colorized terminal output, e.g., `puts "Error".red`. These colors are provided by Foundation's [Ansi](https://api.bridgetownrb.com/Bridgetown/Foundation/Packages/Ansi.html) package. If your output somehow gets "stuck" in a color, you can also call `reset_ansi` on a string.

### Module

#### `nested_within?`

This lets you check if a particular module or class is nested inside of a namespace. For example, `Bridgetown::Resource::Base.nested_within? Bridgetown::Resource` is true, but `Bridgetown::Resource::Base.nested_within? Bridgetown::Model` is false.

#### `nested_parents` / `nested_parent`

The first method will return an array of parent classes/modules within the namespace hierarchy. `Bridgetown::Resource::Base.nested_parents` returns `[Bridgetown::Resource, Bridgetown]`. And `Bridgetown::Resource::Base.nested_parent` returns `Bridgetown::Resource`.

#### `nested_name`

This returns the string identifier of the class/module name without its nested parents. For example: `Bridgetown::Resource::Base.name` would return `"Bridgetown::Resource::Base"`, but `Bridgetown::Resource::Base.nested_name` returns `"Base"`.

### Packages

A few of the features in Foundation are provided in the form of [Inclusive packages](https://codeberg.org/jaredwhite/inclusive). This is a "syntactic sugar" way of accessing utility methods from modules without using mixins directly. You can load in a package by adding `include Inclusive` in a Ruby class and then defining a method for accessing one or more packages:

```ruby
packages def some_package = [Some::Available::Package]

def later_on
  some_package.method_here(...)
end
```

#### `Ansi`

This is used for providing a way to output strings with color in a terminal. (See the docs above on `String`.) [View code here.](https://github.com/bridgetownrb/bridgetown/blob/main/bridgetown-foundation/lib/bridgetown/foundation/packages/ansi.rb)

#### `PidTracker`

This is used for managing pid files in a multiprocess setting. [View code here.](https://github.com/bridgetownrb/bridgetown/blob/main/bridgetown-foundation/lib/bridgetown/foundation/packages/pid_tracker.rb)

#### `SafeTranslations`

This package is used to manage the display of translations which include HTML (although it's not inherently HTML-specific), marking them as "safe". Sample usage:

```ruby
class TranslateWithHTML
  include Inclusive

  packages def translate_package = [Bridgetown::Foundation::Packages::SafeTranslations]

  def translate(key, **options)
    escaper = ->(input) { input.to_s.encode(xml: :attr).gsub(%r{\A"|"\Z}, "") }
    translate_package.translate(key, escaper, :html_safe, **options)
  end
end

# This will escape the value in the provided hash
TranslateWithHTML.new.translate("key.path.to.entry", { name: "Jared White <script>// XSS</script>" })
```

[View code here.](https://github.com/bridgetownrb/bridgetown/blob/main/bridgetown-foundation/lib/bridgetown/foundation/packages/safe_translations.rb)
