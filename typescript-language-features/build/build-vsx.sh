#!/bin/bash
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

NAME="$1"
REPO="$2"
REVISION="$3"

echo building $NAME V $REVISION from repo $REPO
mkdir "$NAME-src"
cd "$NAME-src"
echo cloning $REPO into $NAME && git clone $REPO $NAME
cd $NAME

git submodule init
git submodule update
cd vscode
git checkout $REVISION
cd ..
yarn build:extensions
yarn bundle:extensions
yarn install --ignore-scripts
yarn package-vsix:latest --force

cp dist/$NAME-$REVISION.vsix /
cd /$NAME-src/$NAME/vscode/extensions/$NAME && tar -czvf /$NAME-$REVISION-sources.tar.gz ./
