#!/bin/bash
#
# Copyright (c) 2023 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

set -ex

EXTENSION_NAME="$1"


if test -f "$EXTENSION_NAME/extension.json"; then
    EXTENSION_JSON="$EXTENSION_NAME/extension.json"
else
    echo "Extension $EXTENSION_NAME does not have an extension.json"
    exit
fi

EXTENSION_REPOSITORY=$(cat "$EXTENSION_JSON" | jq -r .repository)
EXTENSION_REVISION=$(cat "$EXTENSION_JSON" | jq -r .revision)

#Defaults
ubi8Image="nodejs-18:1-24"
packageManager="npm@latest"
vsceVersion="2.17.0"

EXTENSION_IMAGE=$(cat "$EXTENSION_JSON" | jq -r .ubi8Image)
if [[ $EXTENSION_IMAGE -eq "null" ]]; then
    EXTENSION_IMAGE=$ubi8Image
fi

EXTENSION_MANAGER=$(cat "$EXTENSION_JSON" | jq -r .packageManager)
if [[ $EXTENSION_MANAGER -eq "null" ]]; then
    EXTENSION_MANAGER=$packageManager
fi

EXTENSION_VSCE=$(cat "$EXTENSION_JSON" | jq -r .vsceVersion)
if [[ $EXTENSION_VSCE -eq "null" ]]; then
    EXTENSION_VSCE=$vsceVersion
fi

echo "Building $EXTENSION_NAME, version $EXTENSION_REPOSITORY"
if test -f "$EXTENSION_NAME/Dockerfile"; then
    docker build --no-cache=true \
        --build-arg extension_name="$EXTENSION_NAME" \
        --build-arg extension_repository="$EXTENSION_REPOSITORY" \
        --build-arg extension_revision="$EXTENSION_REVISION" \
        --build-arg extension_image="$EXTENSION_IMAGE" \
        --build-arg extension_manager="$EXTENSION_MANAGER" \
        --build-arg extension_vsce="$EXTENSION_VSCE" \
        -t "$EXTENSION_NAME"-builder "$EXTENSION_NAME"/
else
    docker build --no-cache=true \
        --build-arg extension_name="$EXTENSION_NAME" \
        --build-arg extension_repository="$EXTENSION_REPOSITORY" \
        --build-arg extension_revision="$EXTENSION_REVISION" \
        --build-arg extension_image="$EXTENSION_IMAGE" \
        --build-arg extension_manager="$EXTENSION_MANAGER" \
        --build-arg extension_vsce="$EXTENSION_VSCE" \
        -t "$EXTENSION_NAME"-builder .
fi

echo "Publishing $EXTENSION_NAME, version $EXTENSION_REPOSITORY"
docker run --cidfile "$EXTENSION_NAME"-builder-id "$EXTENSION_NAME"-builder
BUILDER_CONTAINER_ID=$(cat "$EXTENSION_NAME"-builder-id)
docker cp $BUILDER_CONTAINER_ID:/$EXTENSION_NAME-$EXTENSION_REVISION.vsix ./
docker cp $BUILDER_CONTAINER_ID:/$EXTENSION_NAME-$EXTENSION_REVISION-sources.tar.gz ./
docker stop $BUILDER_CONTAINER_ID
rm ./$EXTENSION_NAME-builder-id

