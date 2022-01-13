---
title: Bridgetown on Fedora
top_section: Setup
category: installation-guides
back_to: installation
ruby_version: 3.0.2
order: 0
---

## Install Ruby

### Using Rbenv

Update your package list:

Then install dependencies:

```sh
sudo dnf install git-core zlib zlib-devel gcc-c++ patch readline readline-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel
```
Install rbenv

```sh
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
```

Install ruby-build to provide `rbenv install`
```sh
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```
Then install Ruby and check the version
```sh
rbenv install {{ resource.data.ruby_version }}
rbenv global {{ resource.data.ruby_version }}

ruby -v
> ruby 3.0.2p107 (2021-07-07 revision 0db68f0233) [x86_64-linux]

gem install bundler -N
````

Check the rbenv command reference for more information [here](https://github.com/rbenv/rbenv#command-reference)


### Using Fedora Repositories

Fedora typically uses a recent version of Ruby that is maintained by the 
[Fedora Ruby special interest group](https://fedoraproject.org/wiki/SIGs/Ruby).

First, update your package list:

```sh
sudo dnf update
```

Then install Ruby as indicated [here](https://developer.fedoraproject.org/tech/languages/ruby/ruby-installation.html) using

```sh
sudo dnf install ruby
```

Verify that ruby is installed

```sh
ruby -v
> ruby 2.6.6p146 (2020-03-31 revision 67876) [x86_64-linux]
```
Then install bundler as indicated [here](https://developer.fedoraproject.org/tech/languages/ruby/bundler-installation.html)

```sh
gem install bundler
```

And that's it! 

## Install Node & Yarn {#node}

Node is a JavaScript runtime that can execute on a server or development machine. Yarn
is a package manager for Node packages. You'll need Node and Yarn in order to install
and use Webpack, the frontend asset compiler that runs alongside Bridgetown.

The easiest way to install Node and Yarn is via the package manager dnf.

```sh
sudo dnf update
sudo dnf install nodejs nodejs-devel
sudo dnf install nodejs-yarn
```

Then verify your installed versions:

```sh
node -v
> v12.19.0
yarn -v
> 1.21.1
```


{%@ "docs/install/bridgetown" %}
