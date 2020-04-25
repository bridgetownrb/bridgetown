const concurrently = require('concurrently');

concurrently([
  { command: "yarn webpack-dev", name: "Webpack", prefixColor: "yellow"},
  { command: "sleep 4; yarn serve", name: "Bridgetown", prefixColor: "green"},
  { command: "sleep 8; yarn sync", name: "Live", prefixColor: "blue"}
], {
  restartTries: 3,
  killOthers: ['failure', 'success'],
}).then(() => {}, () => {});
