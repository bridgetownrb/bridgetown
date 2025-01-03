---
title: Roda Reference Guide
order: 255
top_section: Architecture
category: roda
---

Bridgetown comes with what we like to call an "opinionated distribution" of the [Roda web toolkit](https://roda.jeremyevans.net), meaning we've configured a number of plugins right out of the box for enhanced developer experience.

This base configuration is itself provided by the `bridgetown_server` plugin. On a fresh install of a Bridgetown site, you'll get a `server/roda_app.rb` file with the following:

```ruby
class RodaApp < Roda
  plugin :bridgetown_server

  route do |r|
    r.bridgetown
  end
end
```

The `r.bridgetown` method call spins up Bridgetown's own routing system which is comprised of subclasses of `Bridgetown::Rack::Routes`—or if the `bridgetown-routes` plugin is active, file-based routing (in `src/_routes`) as well.

The `bridgetown_server` plugin configures the following Roda plugins:

* [common_logger](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/CommonLogger.html) - connects Roda up with Bridgetown's logger
* [json](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/Json.html) - allows arrays or hashes returned from a route block to be converted to JSON output automatically, along with setting `application/json` as the content type for the response
* [json_parser](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/JsonParser.html) - parses incoming JSON data and provides it via `r.POST` and also `r.params`

Bridgetown also sets up the [not_found](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/NotFound.html), [exception_page](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/ExceptionPage.html), and [error_handler](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/ErrorHandler.html) plugins to deal with errors that may arise when processing a request.

We also load our custom `ssg` plugin which is loosely based on Roda's `public` plugin and provides serving of static assets using "pretty URLs", aka:

* `/path/to/page` -> `/path/to/page.html` or `/path/to/page/index.html`
* `/path/to/page/` -> `/path/to/page/index.html`

The `bridgetown_ssr` plugin configures these additional plugins:

* [all_verbs](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/AllVerbs.html) - adds routing methods for additional HTTP verbs like PUT, PATCH, DELETE, etc.
* [cookies](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/Cookies.html) - adds response methods for setting or deleting cookies, default path is root (`/`)
* [indifferent_params](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/IndifferentParams.html) - lets you access request params using symbols in addition to strings, and also provides a `params` instance method (no need to use `r.`)
* [route_csrf](https://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/RouteCsrf.html) - this helps protect against cross-site request forgery in form submissions
* [custom_block_results](https://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/CustomBlockResults.html) - lets Roda route blocks return arbitrary objects which can be processed with custom handlers. We use this to enable our `RodaCallable` functionality
* `method_override` - this Bridgetown-supplied plugin looks for the presence of a `_method` form param and will use that to override the incoming HTTP request method. Thus even if a form comes in as POST, if `_method` equals `PUT` the request method will be `PUT`.

If you pass `sessions: true` to the `ssr` initializer in your config, you'll get these plugins added:

* sessions RODA_SECRET_KEY
* flash
