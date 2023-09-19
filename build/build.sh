#!/bin/bash -e
#
# Copyright (c) 2023 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation
#

CLEAN=0

#debug code
set -x

usage ()
{
    echo "Usage: $0 EXTENSION_NAME [--clean]

Example: $0 atlassian.atlascode --clean

Options: 
  --clean     : Run podman system prune -a -f after the build to clean up leftover containers
"
    exit
}

if [[ -z "$1" ]]; then usage; fi
if [[ ! -z "$2" ]] && [[ $2 = "--clean" ]]; then
    CLEAN=1
fi

EXTENSION_NAME="$1"

if [[ $(cat "plugin-config.json" | jq -r '.Plugins["'$EXTENSION_NAME'"]') -eq "null" ]]; then
    echo "Extension $EXTENSION_NAME is not in plugin-config.json"
    exit
fi

function parse_json () {
    echo $(cat "plugin-config.json" | jq -r '.Plugins["'$EXTENSION_NAME'"]["'$1'"]')
}

EXTENSION_REPOSITORY=$(parse_json repository)
EXTENSION_REVISION=$(parse_json revision)

#Defaults
ubi8Image="nodejs-18:1-60"
packageManager="npm@latest"
vsceVersion="2.17.0"

EXTENSION_IMAGE=$(parse_json ubi8Image)
if [[ $EXTENSION_IMAGE -eq "null" ]]; then
    EXTENSION_IMAGE=$ubi8Image
fi

EXTENSION_MANAGER=$(parse_json packageManager)
if [[ $EXTENSION_MANAGER -eq "null" ]]; then
    EXTENSION_MANAGER=$packageManager
fi

EXTENSION_VSCE=$(parse_json vsceVersion)
if [[ $EXTENSION_VSCE -eq "null" ]]; then
    EXTENSION_VSCE=$vsceVersion
fi

echo "Building $EXTENSION_NAME, version $EXTENSION_REPOSITORY"
if test -f "$EXTENSION_NAME/Dockerfile"; then
    podman build --no-cache=true \
        --build-arg extension_name="$EXTENSION_NAME" \
        --build-arg extension_repository="$EXTENSION_REPOSITORY" \
        --build-arg extension_revision="$EXTENSION_REVISION" \
        --build-arg extension_image="$EXTENSION_IMAGE" \
        --build-arg extension_manager="$EXTENSION_MANAGER" \
        --build-arg extension_vsce="$EXTENSION_VSCE" \
        -t "$EXTENSION_NAME"-builder "$EXTENSION_NAME"/
else
    podman build --no-cache=true \
        --build-arg extension_name="$EXTENSION_NAME" \
        --build-arg extension_repository="$EXTENSION_REPOSITORY" \
        --build-arg extension_revision="$EXTENSION_REVISION" \
        --build-arg extension_image="$EXTENSION_IMAGE" \
        --build-arg extension_manager="$EXTENSION_MANAGER" \
        --build-arg extension_vsce="$EXTENSION_VSCE" \
        -t "$EXTENSION_NAME"-builder .
fi

echo "Publishing $EXTENSION_NAME, version $EXTENSION_REPOSITORY"
podman run --cidfile="$EXTENSION_NAME"-builder-id "$EXTENSION_NAME"-builder
BUILDER_CONTAINER_ID=$(cat "$EXTENSION_NAME"-builder-id)
podman cp $BUILDER_CONTAINER_ID:/$EXTENSION_NAME.vsix ./
podman cp $BUILDER_CONTAINER_ID:/$EXTENSION_NAME-sources.tar.gz ./
podman stop $BUILDER_CONTAINER_ID

#debug code
# DISABLED REMOVAL OF BUILDER_ID FILE TO SEE IF IT HELPS
# ls -l
# if [[ -f ./$EXTENSION_NAME-builder-id ]]; then
#     #debug information
#     echo "found file, removing builder id"
#     rm ./$EXTENSION_NAME-builder-id
# fi
#debug code
ls -l

if [[ $CLEAN -eq 1 ]]; then
    podman system prune -a -f
fi

# Get SHA256 of vsix and sources files and add to plugin-manifest.json for the Brew build
PLUGIN_SHA=$(sha256sum $EXTENSION_NAME.vsix)
PLUGIN_SHA=${PLUGIN_SHA:0:64}

FILE=$(cat "plugin-manifest.json" | jq -r ".Plugins[\"$EXTENSION_NAME\"][\"vsix\"] |= \"$PLUGIN_SHA\"")
echo "${FILE}" > "plugin-manifest.json"

SOURCE_SHA=$(sha256sum $EXTENSION_NAME-sources.tar.gz)
SOURCE_SHA=${SOURCE_SHA:0:64}

FILE=$(cat "plugin-manifest.json" | jq -r ".Plugins[\"$EXTENSION_NAME\"][\"source\"] |= \"$SOURCE_SHA\"")
echo "${FILE}" > "plugin-manifest.json"