---
order: 180
title: Deploy to Production
top_section: Publishing Your Site
category: deployment
---

Bridgetown generates your site and saves it to the `output` directory by default. You can
transfer the contents of this directory to almost any hosting provider to make
your site go live.

Bridgetown's included site template automatically provides a Rake task you can run to build both your frontend bundle and your static website:

```shell
bin/bridgetown deploy
```

as part of your deployment process, which will kick off both the `frontend:build` Rake task and the `bridgetown build` commands in that order.

{%@ Note type: :warning do %}
You must set the `BRIDGETOWN_ENV`
environment variable to `production` on the machine or service that's building the
site for deployment. [Read more about environments here.](/docs/configuration/environments/)

This will also help you if you wish to utilize additional logic within your site templates or plugins to determine what's a "development" build vs. "production" build.
{% end %}

{%= toc %}

## Automatic Deployment

We recommend setting up an automatic deployment solution at the earliest opportunity. This way every time you push a commit up to your Git repository on a service such as Codeberg, your site is automatically rebuilt and deployed quickly.

Some popular services include:

### Statichost.eu

[Statichost.eu](https://statichost.eu) is a privacy-first, GDPR-compliant static site hosting provider based in Europe, founded on the belief that it's possible to run a web hosting company without processing any personal data.

To deploy a Bridgetown site on statichost.eu with a repo hosted on [Codeberg](https://codeberg.org) (an open-source European Git forge):

1. Add a `statichost.yml` config file to specify a Docker image for the build process as well as the build command and public output folder. (See example below.)
2. Copy the repo "clone" URL (ending in `.git`) from Codeberg for use in creating a new site project on statichost.eu.
3. You'll need to add a deploy key to your Codeberg repo. When viewing your repo, click **Settings**, then click **Deploy keys** in the sidebar.
4. Before completing your site setup, don’t forget to ensure the `BRIDGETOWN_ENV=production` environment variable is set!
5. Now statichost.eu will attempt a trial build. Assuming all goes well, you will then need to press the **Publish** button to complete the set (as well as set up your DNS appropriately).
6. **Important:** make sure you add a “Forgejo”-style webhook so for every push to Codeberg, your site rebuilds! Go to **Settings** > **Webhooks** on Codeberg and make sure it will ping `https://builder.statichost.eu/YOUR_SITE_NAME`.

If you get stuck on some of these steps, [Codeberg's documentation](https://www.statichost.eu/docs/git-providers/#forgejo-eg-codeberg) should be able to help.

Here's an example `statichost.yml` config file:

```yml
# Docker image to use for building
image: combos/ruby_node:3_22
# Build command
command: bundle install && npm install && bundle exec bridgetown deploy
# Public directory
public: output
```

### Render

[Render](https://render.com) provides the easiest cloud for all your static sites, APIs, databases, and containers. Render is a unified platform which can build and run apps and websites with free SSL, a global CDN, private networks, and auto deploys from Git. Use Render's admin dashboard or write an "infrastructure as code" YAML file to configure all your services at once. The choice is yours.

For easy setup of Bridgetown sites on Render, we've provided this [bundled configuration](/docs/bundled-configurations#render-yaml-configuration).

### Netlify

[Netlify](https://www.netlify.com) is a web developer platform which focuses on productivity and global scale without requiring costly infrastructure. Get set up with continuous deployment, lead gen forms, one click HTTPS, and so much more.

For easy setup of Bridgetown sites on Netlify, we've provided this [bundled configuration](/docs/bundled-configurations#netlify-toml-configuration).

### Fly.io

[Fly.io](https://fly.io) is a platform that focuses on container based deployment. Their service transforms containers into micro-VMs that run on hardware all across the globe. The section below on [Docker](/docs/deployment#docker) has some examples that can be used with Fly.

### GitHub Pages

Much like with GitLab, you can also deploy static sites to [GitHub Pages](https://pages.github.com/). You can make use of [GitHub Actions](https://github.com/features/actions) to automate building and deploying your site to GitHub Pages.

Bridgetown includes a [bundled configuration to set up GitHub pages](/docs/bundled-configurations#github-pages-configuration). You can apply it with the following command:

```shell
bin/bridgetown configure gh-pages
```

Make sure to update your repo's GitHub Pages Settings at `https://github.com/<your-account>/<your-site>/settings/pages` to have the pages Source set to GitHub Actions. You'll also likely need to set a [`base_path`](/docs/configuration/options#build-command-options) in your Bridgetown configuration unless you're setting up a custom domain.

### GitLab Pages

{%@ "docs/help_needed", resource: resource %}

[GitLab pages](https://docs.gitlab.com/ee/user/project/pages/) can host static websites. Create a repository on GitLab,
which we suppose is at https://gitlab.com/bridgetownrb/mysite
Add the following .gitlab-ci.yml file to your project, which we shall suppose is called `mysite` following the documentation setup [instructions](/docs/). The .gitlab-ci.yml file should be in the mysite directory created using `bridgetown new mysite` and should contain

```yaml
image: ruby:2.6

cache:
  paths:
  - vendor

.setup:
  script:
    - apt-get update -yqqq
    - curl -sL https://deb.nodesource.com/setup_20.x | bash -
    - apt update
    - apt-get install -y nodejs
    - export GEM_HOME=$PWD/gems
    - export PATH=$PWD/gems/bin:$PATH
    - gem install bundler
    - gem install bridgetown -N
    - bundle install
    - npm install

test:
  script:
    - !reference [.setup, script]
    - bin/bridgetown deploy
    - bin/bridgetown clean
  except:
    - main

pages:
  script:
    - !reference [.setup, script]
    - bin/bridgetown deploy
    - mv output public
  artifacts:
    paths:
      - public
  only:
    - main
```
Once this file has been created, add it and the other files and folders to the repository, and then push them to GitLab:

```sh
git add .gitlab-ci.yml
git remote add origin https://gitlab.com/bridgetownrb/mysite
git add .
git commit -am "initial commit"
git push -u origin main
```

After the build the site should be live at https://bridgetownrb.gitlab.io/mysite

#### Enable GZip & Brotli compression for GitLab Pages

Most modern browsers support downloading files in a compressed format. This
speeds up downloads by reducing the size of files.

Before serving an uncompressed file, Gitlab Pages checks if the same file exists
with a `.br` or `.gz` extension. If it does, and the browser supports receiving
compressed files, it serves that version instead of the uncompressed one.

This can be achieved by including a `script:` command like this in your
`.gitlab-ci.yml` pages job:

```yaml
pages:
  # Other directives
  script:
    # Add this line right after apt update
    - apt-get install -y brotli
    # Build the public/ directory first
    - find public -type f -regex '.*\.\(htm\|html\|txt\|text\|js\|css\)$' -exec gzip -f -k {} \;
    - find public -type f -regex '.*\.\(htm\|html\|txt\|text\|js\|css\)$' -exec brotli -f -k {} \;
```

For more details, [see the documentation](https://docs.gitlab.com/ee/user/project/pages/introduction.html#serving-compressed-assets).

## Manual Deployment

The most basic method of deployment is transferring the contents of your `output` folder to any web server. You can use something like `scp` to securely copy the folder, or you can use a more advanced tool:

### rsync

Rsync is similar to scp except it can be faster as it will only send changed
parts of files as opposed to the entire file. You can learn more about using
rsync in the [Digital Ocean tutorial](https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories-on-a-vps).

### Docker

Many modern hosting solutions support deploying with a `Dockerfile`. To build a Bridgetown site for one of these services, create a `Dockerfile` in the root directory of your project. See the examples below.

#### Static Site

If you're looking to deploy a static version of your site:

```Dockerfile
FROM combos/ruby_node:3_22 AS builder
ENV BRIDGETOWN_ENV=production

WORKDIR /opt/src
COPY . .

RUN bundle install && npm install && bundle exec bridgetown deploy

FROM lipanski/docker-static-website:latest
COPY --from=builder /opt/src/output .
CMD ["/busybox-httpd", "-f", "-v", "-p", "4000"]
```

#### Dynamic Site

If you want to use Puma as the server directly for [Dynamic Routes & SSR](/docs/routes) support (it's recommended you set up a caching layer in front for static assets like images, CSS, JS, etc.):

```Dockerfile
FROM combos/ruby_node:3_22
ENV BRIDGETOWN_ENV=production

WORKDIR /opt/src
COPY . .

RUN bundle install && npm install && bundle exec bridgetown deploy

EXPOSE 4000
CMD bundle exec bridgetown start --skip-frontend
```

### Dokku

[Dokku](http://dokku.viewdocs.io/dokku) is great if you either want Heroku-style
deployments on a budget or you want more control over your server stack.

This guide assumes you've got a fully-functioning Dokku server up and running
and created an app we'll conveniently call `bridgetown`.

First, add the following environment variables to your app on the server:

```shell
dokku config:set bridgetown BRIDGETOWN_ENV=production NGINX_ROOT=output
```

Next, create a file called `.buildpacks` at the root of your local project with
the following contents to tell Dokku about the app's requirements:

```
https://github.com/heroku/heroku-buildpack-ruby
https://github.com/heroku/heroku-buildpack-nodejs
https://github.com/dokku/buildpack-nginx
```

Also, create an empty file called `.static` in the same location. This file will
tell dokku to run the app as a static website using Nginx.

Finally, add the following line to the `scripts` section in your package.json:

```json
{
  // ...
  "scripts": {
    // ...
    "heroku-postbuild": "bin/bridgetown deploy",
    // ...
  },
  // ...
}
```

The nodejs buildpack will automatically run `npm run heroku-postbuild` at the right
time during the deployment process, so there is nothing left to do. You can now
safely deploy your application:

```shell
git push dokku
```

... and watch your site being built on the server.

### NGINX


Upload the `output` folder to somewhere accessible by NGINX and configure your server. Below is an example of `conf` file:

```nginx
server {
  server_name bridgetown.example.com;
  index index.html;
  root /var/www/bridgetown/output;

  location / {
    rewrite ^(.+)/+$ $1 permanent;
    try_files $uri $uri/index.html $uri.html /index.html;
    access_log /var/www/bridgetown/shared/log/nginx.access.log;
    error_log /var/www/bridgetown/shared/log/nginx.error.log;
  }

  location ^~ /_bridgetown/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }

  listen 443 ssl;
  # You can get a free SSL in https://freessl.cn or using let's encrypt certbot
  ssl_certificate /etc/ssl/certs/bridgetown.example.com.pem;
  ssl_certificate_key /etc/ssl/private/bridgetown.example.com.key;
}

server {
  if ($host = bridgetown.example.com) {
      return 301 https://$host$request_uri;
  }

  listen 80;
  server_name bridgetown.example.com;
  return 404;
}
```
