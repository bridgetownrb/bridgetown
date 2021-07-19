---
title: "A Break from Summer Break to Bring You Bridgetown 0.21.1"
subtitle: |
  We're taking a break from popsicles, river floats, and jazz festivals to bring you our latest release.
author: jared
category: release
---

Things have been a bit quiet here lately due to the hot, lazy days of summer (in the Northern Hemisphere at least). But we're taking a break from popsicles, river floats, and jazz festivals to bring you [our latest release, v0.21.1](https://github.com/bridgetownrb/bridgetown/releases/tag/v0.21.1).

It may be a small point release, but it nevertheless has some cool enhancements!

* **Webpack 5 support**. Yes indeed! If you're ready to hop aboard the latest version of Webpack, we've got you covered. To upgrade an existing site, just run `bundle exec bridgetown webpack update`.  This only works if your site is fairly new, or if you've run `bundle exec bridgetown webpack setup` once before (make sure your files are committed before running setup as it will overwrite your Webpack config!). One other note: if you're still using `node-sass` in your `package.json` dependencies, you might want to consider switching to the newer `sass` (aka Dart Sass) package as well.
* **Babel begone, hello esbuild**. In our updated frontend config, we've switched from using Babel (a transpilation tool for converting the latest JavaScript features to polyfills for wider browser support) to esbuild, improving performance and simplifying the bundling process. At some point in the future, we might even be able to retire Webpack! But for now, Webpack + esbuild = 😍. 
* **Resource Extension API**. If you've ever wondered what it'd be like to add your own methods to resource objects, wonder no more! This is now possible, either in local plugins you write or via third-party gems. The API also forms the basis of our new extension point for "summarization" services. [You can read more about this in the docs here](https://www.bridgetownrb.com/docs/resources#resource-extensions){:data-no-swup="true"}.
* **Heads up!** The configuration option `baseurl` has changed to `base_path` so it's less confusing. Bridgetown will continue to support `baseurl` in your config file for now but it is marked deprecated.

That's all folks. Feel free to [hop in our Discord chat](https://discord.gg/4E6hktQGz4) if you have any questions. We've got some massive features in development for later this year so stick around! 😎