Links marked with this icon 🚪 are internal to Red Hat

This repository builds and publishes VS Code extensions used in both Eclipse Che and in Red Hat OpenShift Dev Spaces (formerly Red Hat CodeReady Workspaces).

Every extension in this repository builds inside a `ubi8` based Dockerfile. The resulting `.vsix` files and sources tarballs are then copied out of the container and published as GitHub release assets. Additionally, for DevSpaces a special [Jenkins Job](https://main-jenkins-csb-crwqe.apps.ocp-c1.prod.psi.redhat.com/job/DS_CI/job/pluginregistry-plugins_3.x) is used to publish devspaces  Every PR merged in this repository will trigger a GitHub release, where the extensions built from that PR will be the release assets in the corresponding GitHub release.

# Contributing
## Repository Structure
`plugin-config.json` contains information about all VS Code extensions.
`plugin-manifests.json` contains information about SHA sums for all built plugins, that are published to [RCM tools](https://download.devel.redhat.com/rcm-guest/staging/devspaces/build-requirements/) 🚪. 

Every extension  **must** have an entry in `plugin-config.json` file. An example entry of a plugin in JSON is as follows:

```js
{
...
  "Plugins": {
...
    atlassian.atlascode: {
      // Repository URL of the extension's git repository
      "repository": "https://github.com/microsoft/vscode-python",
      // The tag/SHA1-ID of the extension's repository which you would like to build
      "revision": "2020.11.358366026",
      // If true, plugin will be updateable during the /build/update-from-ovsx.sh script run
      "update": true,
      // (Optional) Override for UBI8 image name and version
      "ubi8Image": "nodejs-18:1-71",
      // (Optional) Override for name and version of package manager
      "packageManager": "npm@9.6.7",
      // (Optional) Override for version of vsce
      "vsceVersion": "2.17.0"
    },
...
```

Optionally, a `Dockerfile` that builds the extension can be provided inside the extension's folder. Note, this is only needed if the extension requires "special" dependencies to build. If no `Dockerfile` is found in the extensions's folder, then the "generic" `Dockerfile` (found at the root of this repository) will be used. In this case, the only thing needed is the folder matching the extension's name, and the `extension.json` file as outlined above.

## Dockerfile Structure
Should you choose to contribute a `Dockerfile`, the following things are required
* The `Dockerfile` must take the following build-time arguments (i.e. `ARG name`):
    * `extension_repository`
    * `extension_revision`
    * `extension_image`
    * `extension_manager`
    * `extension_vsce`
* The `vsix` file resulting from the build (inside the container) must be located at the root of the container, named `/name-revision.vsix` (where name and revision are the values of the build arg specified above)
* A tarball of the extension's source code (prior to build) must be located at the root of the container, named `/name-revision-sources.tar.gz` (again, where name and revision are the values of the build arg specified above)
