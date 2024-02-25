---
order: 180
title: Deploy to Production
top_section: Publishing Your Site
category: deployment
---

Bridgetown generates your site and saves it to the `output` directory by default. You can
transfer the contents of this directory to almost any hosting provider to make
your site go live.

Bridgetown's included site template automatically provides a Rake task you can run to
build both your frontend bundle and your static website. Simply run

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

## Automatic Deployment

We recommend setting up an automatic deployment solution at the earliest opportunity. This way every time you push a commit up to your Git repository on a service such as GitHub, your site is automatically rebuilt and deployed quickly.

Some popular services include:

### Render

[Render](https://render.com) provides the easiest cloud for all your static sites, APIs, databases, and containers. Render is a unified platform which can build and run apps and websites with free SSL, a global CDN, private networks, and auto deploys from Git. Use Render's simple admin dashboard or write an "infrastructure as code" YAML file to configure all your services at once. The choice is yours.

### Vercel

[Vercel](https://www.vercel.com) combines a great developer experience with an obsessive focus on end-user performance. Changes instantly go live on their global edge network along with SSL encryption and cache invalidation. Vercel is the platform for developers and designers…and those who aspire to become one.

### Netlify

[Netlify](https://www.netlify.com) is a web developer platform which focuses on productivity and global scale without requiring costly infrastructure. Get set up with continuous deployment, lead gen forms, one click HTTPS, and so much more.

### Fly.io

[Fly.io](https://fly.io) is a platform that focuses on container based deployment. Their service transforms containers into micro-VMs that run on hardware all across the globe. The section below on [Docker](/docs/deployment#docker) has some examples that can be used with Fly.

## Manual Deployment

For a simple method of deployment, you can simply transfer the contents of your `output` folder to any web server. You can use something like `scp` to securely copy the folder, or you can use a more advanced tool:

### rsync

Rsync is similar to scp except it can be faster as it will only send changed
parts of files as opposed to the entire file. You can learn more about using
rsync in the [Digital Ocean tutorial](https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories-on-a-vps).

### Docker

Many modern hosting solutions support deploying with a `Dockerfile`. Building a Bridgetown site for one of these services is as easy as creating a `Dockerfile` in the root directory of your project. See the examples below.

#### Static Site

If you're simply looking to deploy a static version of your site.

```Dockerfile
# Build frontend JS and CSS assets using ESbuild
FROM node:alpine as asset_builder
ENV BRIDGETOWN_ENV=production
WORKDIR /assets
COPY . .
RUN yarn install
RUN yarn run esbuild

# Generate your site content as HTML
FROM ruby:alpine as bridgetown_builder
ENV BRIDGETOWN_ENV=production
WORKDIR /app
RUN apk add --no-cache build-base
RUN gem install bundler -N
RUN gem install bridgetown -N
COPY . .
RUN bundle install
COPY --from=asset_builder /assets/output output/
COPY --from=asset_builder /assets/.bridgetown-cache .bridgetown-cache/
RUN ./bin/bridgetown build

# Serve your site in a tiny production container, which serves on port 8043.
FROM pierrezemb/gostatic
COPY --from=bridgetown_builder /app/output /srv/http/
```

#### Dynamic Site

If you're looking to use things like [Dynamic Routes & SSR](/docs/routes).

```Dockerfile
ARG RUBY_VERSION=3.2.2
FROM ruby:$RUBY_VERSION-slim as base

ENV VOLTA_HOME=/usr/local

RUN apt-get update &&\
    apt-get install --yes build-essential git curl

RUN curl https://get.volta.sh | bash &&\
    volta install node@lts yarn@latest

WORKDIR /app

FROM base as gems
COPY Gemfile* .
RUN bundle install

FROM base
COPY . .
COPY --from=base $VOLTA_HOME/bin $VOLTA_HOME/bin
COPY --from=base $VOLTA_HOME/tools $VOLTA_HOME/tools
COPY --from=base /app /app
COPY --from=gems /usr/local/bundle /usr/local/bundle

RUN yarn install
RUN bundle exec bridgetown frontend:build

EXPOSE 4000
CMD bundle exec bridgetown start
```

### GitLab Pages

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
    - curl -sL https://deb.nodesource.com/setup_12.x | bash -
    - curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
    - echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
    - apt update
    - apt-get install -y nodejs yarn
    - export GEM_HOME=$PWD/gems
    - export PATH=$PWD/gems/bin:$PATH
    - gem install bundler
    - gem install bridgetown -N
    - bundle install
    - yarn install

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
    # Add this ligne just after apt update
    - apt-get install -y brotli
    # Build the public/ directory first
    - find public -type f -regex '.*\.\(htm\|html\|txt\|text\|js\|css\)$' -exec gzip -f -k {} \;
    - find public -type f -regex '.*\.\(htm\|html\|txt\|text\|js\|css\)$' -exec brotli -f -k {} \;
```

For more details, [see the documentation](https://docs.gitlab.com/ee/user/project/pages/introduction.html#serving-compressed-assets).

### GitHub Pages

Much like with GitLab, you can also deploy static sites to [GitHub Pages](https://pages.github.com/). You can make use of [GitHub Actions](https://github.com/features/actions) to automate building and deploying your site to GitHub Pages.

Bridgetown includes a [bundled configuration to set up GitHub pages](/docs/bundled-configurations#github-pages-configuration). You can apply it with the following command:

```shell
bin/bridgetown configure gh-pages
```

Make sure to update your repo's GitHub Pages Settings at `https://github.com/<your-account>/<your-site>/settings/pages` to have the pages Source set to GitHub Actions. You'll also likely need to set a [`base_path`](/docs/configuration/options#build-command-options) in your Bridgetown configuration unless you're setting up a custom domain.

### Dokku

[Dokku](http://dokku.viewdocs.io/dokku) is great if you either want Heroku-style
deployments on a budget or you want more control over your server stack.
Deploying to Dokku is quite easy, but as always, there are a few settings
required to make everything run smoothly.

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

The nodejs buildpack will automatically run `yarn heroku-postbuild` at the right
time during the deployment process, so there is nothing left to do. You can now
safely deploy your application:

```shell
git push dokku
```

... and watch your site being built on the server.

### NGINX


Just upload the `output` folder to somewhere accessible by NGINX and configure your server. Below is an example of `conf` file:

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
