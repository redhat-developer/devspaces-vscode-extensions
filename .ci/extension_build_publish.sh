#!/bin/bash
#
# Copyright (c) 2020 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

set -ex

BUILD_PUBLISH="$1"
BUILD_ARGS="--push"
FILES_CHANGED=($(git diff --name-only --diff-filter=d -r "$2" "$3"))
EXTENSIONS_TO_BUILD=()

for file in "${FILES_CHANGED[@]}"
do
    if [[ $file == */extension.json ]]; then
        EXTENSION_NAME=$(echo "$file" | cut -d/ -f 1)
        EXTENSION_JSON=$file
    elif [[ $file == */Dockerfile ]]; then
        EXTENSION_NAME=$(echo "$file" | cut -d/ -f 1)
        if test -f "$EXTENSION_NAME/extension.json"; then
            EXTENSION_JSON="$EXTENSION_NAME/extension.json"
        else
            continue
        fi
    fi
    if ! [[ " ${EXTENSIONS_TO_BUILD[@]} " =~ ${EXTENSION_NAME} ]]; then
        EXTENSIONS_TO_BUILD+=("$EXTENSION_NAME")
        EXTENSION_REPOSITORY=$(cat "$EXTENSION_JSON" | jq -r .repository)
        EXTENSION_REVISION=$(cat "$EXTENSION_JSON" | jq -r .revision)
        echo "Building $EXTENSION_NAME, version $EXTENSION_REPOSITORY"
        if test -f "$EXTENSION_NAME/Dockerfile"; then
            docker build --no-cache=true --build-arg extension_name="$EXTENSION_NAME" --build-arg extension_repository="$EXTENSION_REPOSITORY" \
                --build-arg extension_revision="$EXTENSION_REVISION" -t "$EXTENSION_NAME"-builder "$EXTENSION_NAME"/
        else
            docker build --no-cache=true --build-arg extension_name="$EXTENSION_NAME" --build-arg extension_repository="$EXTENSION_REPOSITORY" \
                --build-arg extension_revision="$EXTENSION_REVISION" -t "$EXTENSION_NAME"-builder .
        fi
        if [[ $BUILD_PUBLISH == 'build-publish' ]]; then
            echo "Publishing $EXTENSION_NAME, version $EXTENSION_REPOSITORY"
            docker run --cidfile "$EXTENSION_NAME"-builder-id "$EXTENSION_NAME"-builder
            BUILDER_CONTAINER_ID=$(cat "$EXTENSION_NAME"-builder-id)
            docker cp $BUILDER_CONTAINER_ID:/$EXTENSION_NAME-$EXTENSION_REVISION.vsix ./
            docker cp $BUILDER_CONTAINER_ID:/$EXTENSION_NAME-$EXTENSION_REVISION-sources.tar.gz ./
            docker stop $BUILDER_CONTAINER_ID
            rm ./$EXTENSION_NAME-builder-id
        fi
    fi
done
