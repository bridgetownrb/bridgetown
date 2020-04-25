const browserSync = require("browser-sync").create();

// You can change these configuration values:
const proxy = "http://localhost:4001"
const port = 4000
const uiPort = 4002

////////////////
// Browsersync
////////////////
browserSync.init({
  open: false,
  notify: false,
  proxy: proxy,
  port: port,
  files: "output/index.html",
  ghostMode: {
    clicks: false,
    forms: false,
    scroll: false,
  },
  reloadDelay: 0,
  injectChanges: false,
  ui: {
    port: uiPort
  },
  snippetOptions: {
    rule: {
      match: /<\/head>/i,
      fn: function (snippet, match) {
        return snippet + match;
      },
    },
  },
});
