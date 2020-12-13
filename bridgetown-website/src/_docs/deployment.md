---
order: 4.5
next_page_order: 4.7
title: Deploying Your Site
top_section: Setup
category: deployment
---

Bridgetown generates your site and saves it to the `output` directory by default. You can
transfer the contents of this directory to almost any hosting provider to make
your site go live.

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

### Vercel

[Vercel](https://www.vercel.com) combines the best developer experience with an obsessive focus on end-user performance. Changes instantly go live on their global edge network. Everything is taken care of for you, from SSL encryption to asset compression and cache invalidation. Vercel is the platform for developers and designers…and those who aspire to become one.

### Netlify

[Netlify](https://www.netlify.com) is a web developer platform which focuses on productivity and global scale without requiring costly infrastructure. Get set up with continuous deployment, lead gen forms, one click HTTPS, and so much more.

### Manual Deployment

For a simple method of deployment, you can simply transfer the contents of your `output` folder to any web server. You can use something like `scp` to securely copy the folder, or you can use a more advanced tool:

### rsync

Rsync is similar to scp except it can be faster as it will only send changed
parts of files as opposed to the entire file. You can learn more about using
rsync in the [Digital Ocean tutorial](https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories-on-a-vps).

### GitLab Pages

[GitLab pages](https://docs.gitlab.com/ee/user/project/pages/) can host static websites. Create a repository on GitLab, 
which we suppose is at https://gitlab.com/bridgetownrb/mysite
Add the following .gitlab-ci.yml file to your project, which we shall suppose is called `mysite` following the documentation setup [instructions](/docs/). The .gitlab-ci.yml file should be in the mysite directory created using `bridgetown new mysite` and should contain

```
image: ruby:2.6

cache:
  paths:
  - vendor

test:
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
  - yarn webpack --mode production
  - bundle exec bridgetown build --baseurl mysite  --url https://bridgetownrb.gitlab.io
  - bundle exec bridgetown clean
  except:
    - master

pages:
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
  - yarn webpack --mode production
  - bundle exec bridgetown build --baseurl mysite --url https://bridgetownrb.gitlab.io
  - mv output public
  artifacts:
    paths:
    - public
  only:
  - master

```
Once this fie has been created, add it and the other files and folders to the repository, and then push them to GitLab:

```
git add .gitlab-ci.yml
git remote add origin https://gitlab.com/bridgetownrb/mysite
git add .
git commit -am "initial commit"
git push -u origin master
```

After the build the site should be live at https://bridgetownrb.gitlab.io/mysite

### GitHub Actions

_description coming soon_

### Dokku

[Dokku](http://dokku.viewdocs.io/dokku) is great if you either want Heroku-style
deployments on a budget or you want more control over your server stack.
Deploying to Dokku is quite easy, but as always, there are a few settings
required to make everything run smoothly.

This guide assumes you've got a fully-functioning Dokku server up and running
and created an app we'll conveniently call `bridgetown`.

First, add the following environment variables to your app on the server:

```shell
$ dokku config:set bridgetown BRIDGETOWN_ENV=production NGINX_ROOT=output
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

```js
{
  // ...
  "scripts": {
    // ...
    "heroku-postbuild": "yarn deploy",
    // ...
  },
  // ...
}
```

The nodejs buildpack will automatically run `yarn heroku-postbuild` at the right
time during the deployment process, so there is nothing left to do. You can now
safely deploy your application:

```shell
$ git push dokku
```

... and watch your site being built on the server.
