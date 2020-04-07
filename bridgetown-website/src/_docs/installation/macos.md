---
title: Bridgetown on macOS
hide_in_toc: true
category: installation
order: 0
---

{% include help_needed.md %}

## Install Command Line Tools
First, you need to install the command-line tools to be able to compile native extensions, open a terminal and run:

```sh
xcode-select --install
```

## Install Ruby

Bridgetown requires **Ruby > {{ site.data.requirements.min_ruby }}**.
macOS Catalina 10.15 comes with ruby 2.6.3, so you're fine.
If you're running a previous macOS system, you'll have to install a newer version of Ruby.

### With Homebrew {#brew}
To run the latest Ruby version you need to install it through [Homebrew](https://brew.sh).

```sh
# Install Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew install ruby
```

Add the brew ruby path to your shell config:

```bash
echo 'export PATH="/usr/local/opt/ruby/bin:$PATH"' >> ~/.bash_profile
```

Then relaunch your terminal and check your updated Ruby setup:

```sh
which ruby
# /usr/local/opt/ruby/bin/ruby

ruby -v
{{ site.data.ruby.current_version_output }}
```

Yay, we are now running current stable Ruby!

### With rbenv {#rbenv}

People often use [rbenv](https://github.com/rbenv/rbenv) to manage multiple
Ruby versions. This is very useful when you need to be able to run a given Ruby version on a project.

```sh
# Install Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install rbenv and ruby-build
brew install rbenv

# Set up rbenv integration with your shell
rbenv init

# Check your installation
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-doctor | bash
```

Restart your terminal for changes to take effect.
Now you can install the Ruby version of our choice, let's go with current latest stable Ruby:

```sh
rbenv install {{ site.data.ruby.current_version }}
rbenv global {{ site.data.ruby.current_version }}
ruby -v
{{ site.data.ruby.current_version_output }}
```

That's it! Head over [rbenv command references](https://github.com/rbenv/rbenv#command-reference) to learn how to use different versions of Ruby in your projects.

## Install Node & Yarn

{:.note.warning}
Documentation coming soon…

## Install Bridgetown

Now all that is left is installing Bundler and Bridgetown.

### Local Install

```sh
gem install --user-install bundler bridgetown
```

and then get your Ruby version using

```sh
ruby -v
{{ site.data.ruby.current_version_output }}
```

Then append your path file with the following, replacing the `X.X` with the first two digits of your Ruby version.

```bash
echo 'export PATH="$HOME/.gem/ruby/X.X.0/bin:$PATH"' >> ~/.bash_profile
```

To check that your gem paths point to your home directory run:

```sh
gem env
```

And check that `GEM PATHS:` points to a path in your home directory.

{: .note .info}
Every time you update Ruby to a version with a different first two digits, you will need to update your path to match.

## Problems?

Check out the [troubleshooting]({{ '/docs/troubleshooting/' | relative_url }}) page or [ask for help on our forum](https://community.bridgetownrb.com).
