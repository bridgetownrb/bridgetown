---
title: Bridgetown on macOS
hide_in_toc: true
category: installation
ruby_version: 2.6.6
order: 0
---

## Install Ruby

Bridgetown requires **Ruby > {{ site.data.requirements.min_ruby }}**.
macOS Catalina 10.15 comes with ruby 2.6.3, so you're fine.
If you're running a previous macOS system, you'll have to install a newer version of Ruby.

### With rbenv {#rbenv}

People often use [rbenv](https://github.com/rbenv/rbenv) to manage multiple
Ruby versions, which comes in handy when you need to run a specific Ruby version on a project.

```sh
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Install rbenv and ruby-build
brew install rbenv

# Set up rbenv integration with your shell
rbenv init
```

Restart your terminal for changes to take effect.

Now you can install a new Ruby version. At the time of this writing, Ruby 2.6.6 is a fast and stable option. You'll also want to install Bundler to manage Rubygem dependencies.

```sh
rbenv install {{ page.ruby_version }}
rbenv global {{ page.ruby_version }}

ruby -v
> ruby 2.6.6p146 (2020-03-31 revision 67876) [x86_64-darwin19]

gem install bundler -N
```

And that's it! Head over [rbenv command references](https://github.com/rbenv/rbenv#command-reference) to learn how to use different versions of Ruby in your projects.

Now jump down to the [Install Node & Yarn](#node) section.

### With Homebrew {#brew}

You may install Ruby directly through [Homebrew](https://brew.sh).

```sh
# Install Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew install ruby
```

Add the brew ruby path to your shell config:

```sh
echo 'export PATH="/usr/local/opt/ruby/bin:$PATH"' >> ~/.bash_profile
```

Then relaunch your terminal and check your updated Ruby setup:

```sh
which ruby
# /usr/local/opt/ruby/bin/ruby

ruby -v
```

Yay, we are now running current stable Ruby!

To set up Bundler for managing Rubygem dependencies as well as Ruby executable paths, run:

```sh
gem install --user-install bundler
```

Then append your path file with the following, replacing the `X.X` with the first two digits of your Ruby version.

```sh
echo 'export PATH="$HOME/.gem/ruby/X.X.0/bin:$PATH"' >> ~/.bash_profile
```

Then relaunch your terminal and check that your gem paths point to your home directory by running:

```sh
gem env
```

And check that `SHELL PATH:` includes to a path to `~/.gem/ruby/X.X.0/bin`

<div class="note" markdown="1">
Every time you update Ruby to a version with a different first two digits, you will need to update your path to match.

You will also need to add `--user-install` to any `gem install` statement you run.
</div>

## Install Node & Yarn {#node}

Node is a Javascript runtime that can execute on a server or development machine. Yarn is a package manager for Node packages. You'll need Node and Yarn in order to install and use Webpack, the frontend asset compiler that runs alongside Bridgetown.

The easiest way to install Node and Yarn is via Homebrew (which should already be installed after following the instructions above).

```sh
brew update
brew install node
brew install yarn
```

Then verify your installed versions:

```sh
node -v
yarn -v
```

## Install Bridgetown

Now all that is left is to install Bridgetown!

```sh
gem install bridgetown -N
```

Now, try to create a new Bridgetown site at `./mysite`:

```sh
bridgetown new mysite
cd mysite
```

Install additional Bridgetown gems and frontend dependencies:

```sh
$ bundle install
$ yarn install
```

Now you should be able to build the site and make it available on a local server:

```sh
$ yarn build && bundle exec bridgetown serve
```

Try opening the site up in [http://localhost:4000](http://localhost:4000){:target="_blank"}. See something? Awesome, you're ready to roll! If not, try revisiting your installation and setup steps, and if all else fails, [reach out to the Bridgetown community for support](/docs/community/).
