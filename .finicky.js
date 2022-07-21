module.exports = {
  defaultBrowser: "Firefox",
  handlers: [{
      // Open apple.com urls in Safari
      match: finicky.matchHostnames(["apple.com"]),
      browser: "Safari"
  }, {
      match: finicky.matchHostnames(["google.com", /.*\.google.com$/, "basecamp.com", /.*\.basecamp.com$/, /.*\.zp.io$/, /.*\.trello.com$/, /.*\.accessible360.com$/]),
      browser: "Google Chrome"
  },
    {
      match: finicky.matchHostnames([/.*\.docker.localhost$/, /.*\.dev$/, /.*\.github.com$/, "github.com"]),
      browser: "Firefox Developer Edition"
  }
  ]
};
