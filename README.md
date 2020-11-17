# codeready-workspaces-vscode-extensions
This repository builds and publishes VS Code extensions used in CodeReady Workspaces.

Every extension in this repository builds inside a `ubi8` based Dockerfile. The resulting `.vsix` files and sources tarballs are then copied out of the container and published as GitHub release assets. Every PR merged in this repository will trigger a GitHub release, where the extensions built from that PR will be the release assets in the corresponding GitHub release.

# Contributing
## Repository Structure
Every folder in this repository belongs to a VS Code extension. For example, the `Dockerfile` that builds the `vscode-python` extension would live in the `/vscode-python` folder.

Every extension folder **must** have an `extension.json` file at its root. The schema of this JSON file is as follows:

```js
{
  // Repository URL of the extension's git repository
  "repository": "https://github.com/microsoft/vscode-python",
  // The tag/SHA1-ID of the extension's repository which you would like to build
  "revision": "2020.11.358366026"
}
```

Optionally, a `Dockerfile` that builds the extension can be provided inside the extension's folder. Note, this is only needed if the extension requires "special" dependencies to build. If no `Dockerfile` is found in the extensions's folder, then the "generic" `Dockerfile` (found at the root of this repository) will be used. In this case, the only thing needed is the folder matching the extension's name, and the `extension,json` file as outlined above.

## Dockerfile Structure
Should you choose to contribute a `Dockerfile`, the following things are required
* The `Dockerfile` must take the following build-time arguments (i.e. `ARG name`):
    * `extension_repository`
    * `extension_revision`
    * `extension_name`
* The `vsix` file resulting from the build (inside the container) must be located at the root of the container, named `/name-revision.vsix`
* A tarball of the extension's source code (prior to build) must be located at the root of the container, named `/name-revision-sources.tar.gz`