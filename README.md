<p align="center">
  <a href="https://www.bridgetownrb.com">
    <img src="https://www.bridgetownrb.com/images/bridgetown-logo-twitter-card.jpg" alt="Bridgetown" width="750" />
  <a/>
</p>

<h1 align="center">
  <a href="https://www.bridgetownrb.com">Bridgetown</a>
</h1>

Bridgetown is a Webpack-aware, Ruby-powered static site generator for the modern [Jamstack](https://bridgetownrb.com/docs/jamstack/) era. Bridgetown takes your content and frontend assets, renders Markdown and Liquid templates, and exports a complete website ready to be served by Jamstack services like Netlify or traditional web servers like Nginx.

[![Build Status](https://github.com/bridgetownrb/bridgetown/workflows/build/badge.svg)](https://github.com/bridgetownrb/bridgetown/actions?query=workflow%3Abuild+branch%3Amaster)
[![Gem Version](https://img.shields.io/gem/v/bridgetown.svg)](https://rubygems.org/gems/bridgetown)
[![Licensed MIT](https://img.shields.io/badge/license-MIT-yellowgreen.svg)](LICENSE)
[![Join the Discord Chat](https://img.shields.io/discord/711236503493148733?color=forestgreen&logo=discord)](https://discord.gg/V56yUWR)
[![PRs welcome!](https://img.shields.io/badge/PRs-welcome-blue.svg)](https://github.com/bridgetownrb/bridgetown/blob/master/CONTRIBUTING.md)

---

## Special Thanks to Our Founding Members! 🙏 🎉

Say howdy 👋 to our growing list of the first twenty sponsors of Bridgetown on GitHub.
[You too can join this list and sponsor Bridgetown!](https://github.com/sponsors/jaredcwhite)

|<img src="https://avatars.githubusercontent.com/pilotcph?s=256" alt="pilotcph" width="128" />|<img src="https://avatars.githubusercontent.com/andrewmcodes?s=256" alt="andrewmcodes" width="128" />|<img src="https://avatars.githubusercontent.com/miatrinity?s=256" alt="miatrinity" width="128" />|<img src="https://avatars.githubusercontent.com/marcoroth?s=256" alt="marcoroth" width="128" />|
|:---:|:---:|:---:|:---:|
|<a href="https://twitter.com/cabgfx">@cabgfx</a>|<a href="https://twitter.com/andrewmcodes">@andrewmcodes</a>|<a href="https://github.com/miatrinity">@miatrinity</a>|<a href="https://www.twitter.com/marcoroth_">@marcoroth_</a>|You Next?|
|<a href="http://www.pilotcph.dk">Website</a>|<a href="https://andrewm.codes">Website</a>|<a href="https://railsnew.io/">Website</a>|<a href="https://marcoroth.dev">Website</a>|

---

## Background

Bridgetown started life as a fork of the granddaddy of static site generators, [Jekyll](https://jekyllrb.com). Spearheaded by Portland-based web studio [Whitefusion](https://whitefusion.io) and with a brand new set of [project goals](https://bridgetownrb.com/docs/philosophy/) and [a future roadmap](https://bridgetownrb.com/about/), our pledge is to ramp up adding new features at a steady and predictable pace, grow the open source community around the project, and ensure a lively future for a top-tier Ruby-based static site generator moving forward. 

## Start Here

* [Install](https://bridgetownrb.com/docs/) the Bridgetown gem
* Familiarize yourself with the [Command Line Usage](https://bridgetownrb.com/docs/command-line-usage/) and [Site Configuration](https://bridgetownrb.com/docs/configuration/)
* Explore the best options for [Deploying Your Site](https://bridgetown.rb/docs/deployment) when it's ready to go live
* Have questions? Check out our official [Bridgetown Community forum](https://community.bridgetownrb.com/) or [chat on Discord](https://discord.gg/V56yUWR)
* [Fork Bridgetown](https://github.com/bridgetownrb/bridgetown/fork) and contribute your own improvements!

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

If you'd like to hack away on Bridgetown directly, you'll need to clone this repo and ensure the test suite passes. Note that this is a "monorepo", meaning that multiple Rubygem codebases are stored within a single repo.

```shell
$ git clone git@github.com:bridgetownrb/bridgetown.git
$ cd bridgetown
$ bundle # install development gems
$ bundle exec rake # run the full test suite
```

After making changes in `bridgetown-core`, if you want to run a single unit test, you can use the command:

```shell
$ script/test test/test_foo.rb
```

If you are only updating a Cucumber .feature file, you can use the command:

```shell
$ script/cucumber features/foo.feature
```

Both `script/test` and `script/cucumber` can be run without arguments to run its entire respective suite.

To switch one of your website repos to using the local gem, add the local gem path to
the site's Gemfile as follows:

```ruby
gem "bridgetown-core", path: "/path/to/bridgetown/bridgetown-core"
```

## Need help?

If you don't find the answer to your problem in our [docs](https://bridgetownrb.com/docs/), ask the [community](https://bridgetownrb.com/docs/community/) for help.

## Code of Conduct

In order to have a more open and welcoming community, Bridgetown adheres to a
[code of conduct](CODE_OF_CONDUCT.md) adapted from the Contributor Covenant.

Please adhere to this code of conduct in any interactions you have in the
Bridgetown community. It is strictly enforced on all official Bridgetown
repositories, websites, and resources. If you encounter someone violating
these terms, please let one of our [core team members](mailto:maintainers@bridgetownrb.com) know and we will address it as soon as possible.

## Contributors

Bridgetown is built by:

|<img src="https://avatars.githubusercontent.com/jaredcwhite?s=256" alt="jaredcwhite" width="128" />|<img src="https://avatars.githubusercontent.com/jaredmoody?s=256" alt="jaredmoody" width="128" />|<img src="https://avatars.githubusercontent.com/andrewmcodes?s=256" alt="andrewmcodes" width="128" />|<img src="https://avatars.githubusercontent.com/ParamagicDev?s=256" alt="ParamagicDev" width="128" />|<img src="https://www.gravatar.com/avatar/00000000000000000000000000000000?d=identicon&s=128&" alt="" width="128" />|
|:---:|:---:|:---:|:---:|:---:|
|@jaredcwhite|@jaredmoody|@andrewmcodes|@ParamagicDev|You Next?|
|Portland, OR|Portland, OR|Wilmington, NC|Providence, RI|Anywhere|

Interested in joining the Bridgetown Core Team? Send a DM to Jared on the [Bridgetown Community forum](https://community.bridgetownrb.com) and let's chat!

## License

The gem is available as open source under the terms of the [MIT LICENSE](./LICENSE) file.
