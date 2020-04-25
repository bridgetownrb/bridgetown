const browserSync = require("browser-sync").create();

browserSync.init({
  open: false,
  notify: false,
  proxy: "http://localhost:4000",
  port: 4001,
  files: "output/index.html",
  ghostMode: {
    clicks: false,
    forms: false,
    scroll: false,
  },
  reloadDelay: 0,
  injectChanges: false,
  snippetOptions: {
    rule: {
      match: /<\/head>/i,
      fn: function (snippet, match) {
        return snippet + match;
      },
    },
  },
});
