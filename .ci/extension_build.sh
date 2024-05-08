#!/bin/bash
#
# Copyright (c) 2024 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
# 
# This script is used to check for updates to the Visual Studio plugins listed in plugin-config.json.

set -ex

echo "Checking for updates to the Visual Studio plugins listed in plugin-config.json"

MAIN_BRANCH="devspaces-3-rhel-8"
curl -sSLo plugin-config-main.json https://raw.githubusercontent.com/redhat-developer/devspaces-vscode-extensions/$MAIN_BRANCH/plugin-config.json

pluginsConfig=$(jq -r '.Plugins | keys[]' <plugin-config.json)
pluginsConfigMain=$(jq -r '.Plugins | keys[]' <plugin-config-main.json)

for plugin in $pluginsConfig; do
    # If it is a new extension and doesn't exist in the main branch, try to build it
    if [[ ! " ${pluginsConfigMain[*]} " =~ $plugin ]]; then
        echo "New extension found: $plugin"
        echo "Building $plugin"
        ./build/build.sh "$plugin" --clean
        continue
    fi
    # If it is an existing extension, check if the revision has changed
    revision=$(jq -r --arg plugin "$plugin" '.Plugins[$plugin].revision' <plugin-config.json)
    revisionMain=$(jq -r --arg plugin "$plugin" '.Plugins[$plugin].revision' <plugin-config-main.json)
    if [[ "${revision}" != "${revisionMain}" ]]; then
        echo "Revision changed for $plugin"
        echo "Building $plugin"
        ./build/build.sh "$plugin" --clean
    fi
done
