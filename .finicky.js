module.exports = {
  defaultBrowser: "Firefox Developer Edition",
  handlers: [{
      // Open apple.com and example.org urls in Safari
      match: finicky.matchDomains(["apple.com", "example.org"]),
      browser: "Safari"
  }, {
      // Open any url including the string "workplace" in Firefox
      match: ".vm",
      browser: "Firefox Developer Edition"
  },
    {
      // Open any url including the string "workplace" in Firefox
      match: finicky.matchDomains(["reddit.com"]),
      browser: "Brave Browser"
  }
  ];
}
