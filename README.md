# [Bridgetown](https://bridgetownrb.com/)

[![Gem Version](https://img.shields.io/gem/v/bridgetown.svg)](https://rubygems.org/gems/bridgetown)
[![Join the chat at https://gitter.im/bridgetownrb/bridgetown](https://badges.gitter.im/bridgetownrb/bridgetown.svg)](https://gitter.im/bridgetownrb/bridgetown?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Bridgetown is a Webpack-aware, Ruby-based static site generator for the modern JAMstack era. Bridgetown takes your content and frontend assets, renders Markdown and Liquid templates, and exports a complete website ready to be served by JAMstack services like Netlify or traditional web servers like Nginx.

## Background

Bridgetown started life as a fork of the granddaddy of static site generators, [Jekyll](https://jekyllrb.com). Spearheaded by Portland-based web studio [Whitefusion](https://whitefusion.io) and with a brand new set of [project goals](https://bridgetownrb.com/docs/philosophy/) and [a future roadmap](https://bridgetownrb.com/about/), our pledge is to ramp up adding new features at a steady and predictable pace, grow the open source community around the project, and ensure a healthy future for a top-tier Ruby-based static site generator moving forward. 

## Start Here

* [Install](https://bridgetownrb.com/docs/) the Bridgetown gem
* Familiarize yourself with the [Command Line Usage](https://bridgetownrb.com/docs/command-line-usage/) and [Site Configuration](https://bridgetownrb.com/docs/configuration/)
* Explore the best options for [Deploying Your Site](https://bridgetown.rb/docs/deployment) when it's ready to go live
* Have questions? Check out our official [Bridgetown Community form](https://community.bridgetownrb.com/) or [chat on Gitter](https://gitter.im/bridgetownrb/bridgetown)
* [Fork Bridgetown](https://github.com/bridgetown/bridgetown/fork) and contribute your own improvements!

## Get Up to Speed

* Explore the [Folder Structure](https://bridgetownrb.com/docs/structure) of a Bridgetown website
* Start adding [Pages](https://bridgetownrb.com/docs/pages/) and [Posts](https://bridgetownrb.com/docs/posts/)
* Learn how [Front Matter](https://bridgetownrb.com/docs/front-matter/) works
* Put information on your site with [Variables](https://bridgetownrb.com/docs/variables/) and [Data Files](https://bridgetownrb.com/docs/datafiles/)
* Customize the [Permalinks](https://bridgetownrb.com/docs/structure/permalinks/) your posts are generated with
* Use the built-in [Liquid Tags and Filters](https://bridgetownrb.com/docs/liquid/) to author sophisticated content and template designs
* Extend with [Custom Plugins](https://bridgetownrb.com/docs/plugins/) to generate content specific to your site
* Discover how to add [Frontend Assets](https://bridgetownrb.com/docs/frontend-assets/) using Webpack for a modern Javascript & CSS build pipeline

## Testing Locally

If you'd like to hack away on Bridgetown directly, you'll need to clone this repo and ensure the test suite passes.

```shell
$ git clone git@github.com:bridgetownrb/bridgetown.git
$ cd bridgetown/bridgetown-core
$ script/bootstrap # install development gems
$ script/cibuild # run the full test suite
```

To switch one of your website repos to using the local gem, alter the site's Gemfile as follows:

```ruby
gem "bridgetown-core", path: "/path/to/bridgetown-core"
```

## Need help?

If you don't find the answer to your problem in our [docs](https://bridgetownrb.com/docs/), ask the [community](https://bridgetownrb.com/docs/community/) for help.

## Code of Conduct

In order to have a more open and welcoming community, Bridgetown adheres to a
[code of conduct](CODE_OF_CONDUCT.markdown) adapted from the Ruby on Rails code of
conduct.

Please adhere to this code of conduct in any interactions you have in the
Bridgetown community. It is strictly enforced on all official Bridgetown
repositories, websites, and resources. If you encounter someone violating
these terms, please let one of our [core team members](mailto:maintainers@bridgetownrb.com) know and we will address it as soon as possible.

## Contributors

`bridgetown` is built by:

|<img src="https://avatars.githubusercontent.com/jaredcwhite?s=256" alt="jaredcwhite" width="128" />|<img src="https://www.gravatar.com/avatar/00000000000000000000000000000000?d=identicon&s=128&" alt="" width="128" />|
|:---:|
|@jaredcwhite|You Next?|
|Portland|Anywhere|

## License

The gem is available as open source under the terms of the [MIT LICENSE](./LICENSE) file.
