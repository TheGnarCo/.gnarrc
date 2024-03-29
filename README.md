```
                        ______  _____
                        | ___ \/  __ \
   __ _ _ __   __ _ _ __| |_/ /| /  \/
  / _` | '_ \ / _` | '__|    / | |
 | (_| | | | | (_| | |  | |\ \ | \__/\
(_)__, |_| |_|\__,_|_|  \_| \_| \____/
   __/ |
  |___/
```
## Gnarly Opinions, Codified.

### What is .gnarRC?

`.gnarRC` is a collection of codified opinions for things that we do, but do infrequently. Each folder holds the config files and any relevant dependencies for a given tool so that we can introduce our best practices into projects as quickly and painlessly as possible.

### Why are some of these files weird? `.dev.deps`? `fragment-package.json`?

This repo is used as a source of truth for the [gnar-cli](https://www.github.com/TheGnarCo/gnar-cli) tool, and these files are meant to be human-understandable but machine readable. `.dev.deps` are meant to be fed to `yarn add`, and `fragment-package.json` is a JSON object that will be merged with the project's package.json, but is not itself a valid package.json.

These may change over time, or get more traditional names, rather than these chosen somewhat randomly.

### How do I Contribute?

See [CONTRIBUTING.MD](/CONTRIBUTING.md)

## About The Gnar Company

![The Gnar Company](https://avatars0.githubusercontent.com/u/17011419?s=100&v=4)

If you’re ready to dream it, we’re ready to build it. The Gnar is a custom software company ready to tackle your biggest challenges. Visit [The Gnar Company website](https://www.thegnar.com/) to learn more about us or [contact us](https://www.thegnar.com/contact) to see how we can help design and develop your product.
