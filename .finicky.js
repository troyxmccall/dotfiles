module.exports = {
  defaultBrowser: "Firefox Developer Edition",
  handlers: [{
      // Open apple.com urls in Safari
      match: finicky.matchDomains(["apple.com"]),
      browser: "Safari"
  }, {
      match: finicky.matchDomains(["google.com"]),
      browser: "Google Chrome"
  },
    {
      match: finicky.matchDomains(["reddit.com", "twitter.com", "instagram.com", "tumblr.com", "amazon.com"]),
      browser: "Brave Browser"
  }
  ]
};
