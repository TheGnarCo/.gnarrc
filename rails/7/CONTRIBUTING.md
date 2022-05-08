## Contributing to .gnarRC

Feel free to dive in! [Open an issue](https://github.com/theGnarCo/gnar-cli/issues/new) or submit PRs.

### "Deploying" to "Production": the `prod-cli` branch

tl;dr: `gnar-cli` reads from the `prod-cli` branch. Keep it in sync with `main` unless there are breaking directory changes. In those cases, time the release to coincide with the matching release of `gnar-cli`.

One of the benefits of this repo is that it allows us to update the configuration settings of `gnar-cli` *without* needing to push out a new version and have people update their `gnar-cli`'s. Accordingly, his repo does not traditionally "Deploy" in the traditional sense. Github itself is the source of truth and the repository and what `gnar-cli` uses to power its configuration magicks.

However, for `gnar-cli` to directly from `main` would make changing this repo a little perilous, especially if we changed the directory structure in any meaningful way. We'd have to push out a new version of `gnar-cli` any time we did that, and that kind of defeats the point, don't you think?

Instead, we have the `prod-cli` branch, which exists as a sort of pseudo-production. `gnar-cli` will soon pull directly from this branch, allowing us to get squirrely on main and then strategically "deploy" directory changes to coincide with new releases of `gnar-cli`.

If your change doesn't fundamentally alter the structure of the directories, then it's safe to just push it directly to `prod-cli`.
