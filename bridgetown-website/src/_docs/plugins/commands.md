---
title: Commands
hide_in_toc: true
order: 0
category: plugins
---

{% render "docs/help_needed", page: page %}

Bridgetown can be extended with plugins which provide
subcommands for the `bridgetown` executable. This is possible by including the
relevant plugins in a `Gemfile` group called `:bridgetown_plugins`:

```ruby
group :bridgetown_plugins do
  gem "my_fancy_bridgetown_plugin"
end
```

Each `Command` must be a subclass of the `Bridgetown::Command` class and must
contain one class method: `init_with_program`. An example:

```ruby
class MyNewCommand < Bridgetown::Command
  class << self
    def init_with_program(prog)
      prog.command(:new) do |c|
        c.syntax "new [options]"
        c.description 'Create a new Bridgetown site.'

        c.option 'dest', '-d DEST', 'Where the site should go.'

        c.action do |args, options|
          Bridgetown::Site.new_site_at(options['dest'])
        end
      end
    end
  end
end
```

Commands should implement this single class method:

<table class="settings bigger-output">
  <thead>
    <tr>
      <th>Method</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <p><code>init_with_program</code></p>
      </td>
      <td><p>
        This method accepts one parameter, the
        <code><a href="https://github.com/jekyll/mercenary#readme">Mercenary::Program</a></code>
        instance, which is the Bridgetown program itself. Upon the program,
        commands may be created using the above syntax. For more details,
        visit the <a href="https://github.com/jekyll/mercenary">Mercenary repository</a>.
      </p></td>
    </tr>
  </tbody>
</table>
