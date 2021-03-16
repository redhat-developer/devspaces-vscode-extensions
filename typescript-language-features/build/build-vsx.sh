#!/bin/bash
#
# Copyright (c) 2020 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

echo $1 $2 $3 # name, repo, revision
mkdir "$1-src"
cd "$1-src"
echo cloning $2 into $1 && git clone $2 $1
cd $1

sed -i 's/forcePackaging = false/forcePackaging = true/' src/package-vsix.js 

git submodule init
git submodule update
cd vscode
git checkout $3
cd ..
yarn build:extensions
yarn bundle:extensions
yarn install --ignore-scripts
yarn package-vsix:latest --force
ls
echo whats in dist
ls dist
cp dist/$1-$3.vsix /
