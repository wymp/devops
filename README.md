Devops Utils
============================================================================================================

Currently this only contains some github actions that I use across my various projects and a script or two. Maybe
someday it'll have more? :shrug:

## TOC

### Actions

_Misc Github actions that may be useful._

* [setup-node-pnpm](./actions/setup-node-pnpm/action.yml) - Given a repo that uses `pnpm`, with node and pnpm versions
  specified in `package.json::engines`, checks out the repo, uses `actions/setup-node` to install node to the specified
  version, installs `pnpm`, sets up caching for the `pnpm` store, and optionally installs dependencies. The specified
  node version must be `nvm`-compatible, but the `pnpm` version may be any valid npm version specification. See action
  manifest for more details. 


### Scripts

_Misc scripts that may be helpful in actions or stand-alone_

* [getEngineVersion.js](./scripts/getEngineVersion.js) - Given a `package.json` file with an `engines` field, get the
  specified version of the given engine. See `./scripts/getEngineVersion.js --help` for more information.
* [version-bump.sh](./scripts/version-bump.sh) - Given a monorepo with a top-level `package.json` file and one or more
  subdirectories containing sub-packages, bump the version of the top-level `package.json` file and copy that version
  to all sub-packages. See `./scripts/version-bump.sh --help` for more information.
