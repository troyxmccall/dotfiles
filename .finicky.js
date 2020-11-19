module.exports = {
  defaultBrowser: "Firefox Developer Edition",
  handlers: [{
      // Open apple.com urls in Safari
      match: finicky.matchHostnames(["apple.com"]),
      browser: "Safari"
  }, {
      match: finicky.matchHostnames(["google.com", /.*\.google.com$/, "basecamp.com", /.*\.basecamp.com$/, /.*\.zp.io$/, /.*\.trello.com$/]),
      browser: "Google Chrome"
  },
    {
      match: finicky.matchHostnames(["reddit.com", "twitter.com", "instagram.com", "tumblr.com", "amazon.com","mega.nz"]),
      browser: "Brave Browser"
  }
  ]
};
