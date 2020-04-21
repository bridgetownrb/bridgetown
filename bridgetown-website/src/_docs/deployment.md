---
order: 4.5
next_page_order: 5
title: Deploying Your Site
top_section: Setup
category: deployment
---

Bridgetown generates your site and saves it to the `output` directory by default. You can
transfer the contents of this directory to almost any hosting provider to get
your site live.

Bridgetown's included site template automatically provides a Yarn script you can run to
build both your Webpack bundle and your website. Simply run

```shell
yarn deploy
```

as part of your deployment process, which will kick off both the `webpack` and the `bridgetown build` commands in that order.

If you wish to utilize additional logic within your site templates or plugins to
determine what's a "development" build vs. "production" build, set the `BRIDGETOWN_ENV`
environment variable to `production` on the machine or service that's building the
site for deployment. [Read more about environments here.](/docs/configuration/environments/)

## Automatic Deployment

We recommend setting up an automatic deployment solution at the earliest opportunity. This way every time you push a commit up to your Git repository on a service such as GitHub, your site is automatically rebuilt and deployed quickly.

Some popular services include:

### Netlify

[Netlify](https://www.netlify.com) provides Global CDN, Continuous Deployment, one click HTTPS and [much more](https://www.netlify.com/features/), providing developers a robust toolset for modern web projects without added complexity.

## Aerobatic

[Aerobatic](https://www.aerobatic.com) has custom domains, global CDN distribution, basic auth, CORS proxying, and a growing list of plugins all included.

### GitHub Actions

_description coming soon_

## Manual Deployment

For a simple method of deployment, you can simply transfer the contents of your `output` folder to any web server. You can use something like `scp` to securely copy the folder, or you can use a more advanced tool:

### rsync

Rsync is similar to scp except it can be faster as it will only send changed
parts of files as opposed to the entire file. You can learn more about using
rsync in the [Digital Ocean tutorial](https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories-on-a-vps).
