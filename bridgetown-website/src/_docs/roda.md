---
title: Roda Reference Guide
order: 255
top_section: Architecture
category: roda
---

Bridgetown comes with what we like to call an "opinionated distribution" of the [Roda web toolkit](https://roda.jeremyevans.net), meaning we've configured a number of plugins right out of the box for enhanced developer experience.

{%@ Note do %}
For a general overview of how to author server-side code, see [Server-Rendered Routes](/docs/routes).
{% end %}

This base configuration is itself provided by the `bridgetown_server` plugin. On a fresh install of a Bridgetown site, you'll get a `server/roda_app.rb` file with the following:

```ruby
class RodaApp < Roda
  plugin :bridgetown_server

  route do |r|
    r.bridgetown
  end
end
```

The `r.bridgetown` method call spins up Bridgetown's own routing system which is comprised of subclasses of `Bridgetown::Rack::Routes`and if the `bridgetown-routes` plugin is active, file-based routing (in `src/_routes`) as well.

The `bridgetown_server` plugin configures the following Roda plugins:

* [common_logger](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/CommonLogger.html) - connects Roda up with Bridgetown's logger
* [json](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/Json.html) - allows arrays or hashes returned from a route block to be converted to JSON output automatically, along with setting `application/json` as the content type for the response
* [json_parser](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/JsonParser.html) - parses incoming JSON data and provides it via `r.POST` and also `r.params`

Bridgetown also sets up the [not_found](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/NotFound.html), [exception_page](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/ExceptionPage.html), and [error_handler](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/ErrorHandler.html) plugins to deal with errors that may arise when processing a request.

We also load our custom `ssg` plugin which is loosely based on Roda's `public` plugin and provides serving of static assets using "pretty URLs", aka:

* `/path/to/page` -> `/path/to/page.html` or `/path/to/page/index.html`
* `/path/to/page/` -> `/path/to/page/index.html`

If you add `init :ssr` to your [Initializers](/docs/configuration/initializers) config, the `bridgetown_ssr` plugin is loaded which configures these additional plugins:

* [all_verbs](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/AllVerbs.html) - adds routing methods for additional HTTP verbs like PUT, PATCH, DELETE, etc.
* [cookies](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/Cookies.html) - adds response methods for setting or deleting cookies, default path is root (`/`)
* [indifferent_params](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/IndifferentParams.html) - lets you access request params using symbols in addition to strings, and also provides a `params` instance method (no need to use `r.`)
* [route_csrf](https://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/RouteCsrf.html) - this helps protect against cross-site request forgery in form submissions
* [custom_block_results](https://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/CustomBlockResults.html) - lets Roda route blocks return arbitrary objects which can be processed with custom handlers. We use this to enable our [RodaCallable](/docs/routes#callable-objects-for-rendering-within-blocks) functionality
* `method_override` - this Bridgetown-supplied plugin looks for the presence of a `_method` form param and will use that to override the incoming HTTP request method. Thus even if a form comes in as POST, if `_method` equals `PUT` the request method will be `PUT`.

If you pass `sessions: true` to the `ssr` initializer in your config, you'll get these plugins added:

* [sessions](https://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/Sessions.html) - adds support for cookie-based session storage (aka a small amount of key-val data storage which persists across requests for a single client). You'll need to have `RODA_SECRET_KEY` defined in your environment. To make this easy in local development, you should set up the [Dotenv gem](/docs/configuration/initializers#dotenv). Setting up a secret key is a matter of running `bin/bridgetown secret` and then copying the key to `RODA_SECRET_KEY`.
* [flash](https://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/Flash.html) - provides a `flash` object you can access from both routes and view templates.

The following `flash` methods are available:

* `flash.info = "..."` / `flash.info` - set an informational message in a route which can then be read once after a redirect.
* `flash.alert = "..."` / `flash.alert` - set an alert message in a route which can then be read once after a redirect.
* `flash.now` - lets you set and retrieve flash messages (both `.info` and `.alert`) for the current request/response cycle.

## Bridgetown Route Classes

If you've come to Bridgetown already familiar with Roda, you may be wondering what `Bridgetown::Rack::Routes` is and how it works.

Because a traditional Roda application isn't oriented towards an architecture which plays well with Zeitwerk-based reloading in development, we decided to eschew Roda's recommended solutions for creating multiple route files (such as the `hash_branches` plugin) in favor of a class-based solution.

During the `r.bridgetown` routing process, every loaded `Bridgetown::Rack::Routes` class is evaluated in turn (sorted by [priority](/docs/routes#priority-flag)) until a route handler has been found (or in lieu of that, a generic 404 response is returned). Route handlers are provided via the `route` class method, and the block you provide is evaluated in an instance of that class (not the Roda application itself).

{%@ Note do %}
You can still access methods of the Roda application from within a route block because `Bridgetown::Rack::Routes` defines `method_missing` and delegates calls accordingly. So for example if you were to call `flash` in your route block, that call would be passed along to the Roda application. However, if for some reason you were to write `def flash` to create an instance method, you'd no longer have access to Roda's `flash`. So it's recommended that if you do write custom instance methods, you avoid using names which interfere with typical Roda app methods.
{% end %}
