#!/bin/bash
#
# Copyright (c) 2023 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

set -e

PLUGINS=$(cat plugin-config.json | jq -r '.Plugins | keys[]')
UPDATES=""

for EXTENSION_NAME in $PLUGINS
do
  UPDATE=$(cat "plugin-config.json" | jq -r .Plugins[\"$EXTENSION_NAME\"][\"update\"])

  if [ "$UPDATE" = "false" ]; then continue; fi

  EXTENSION_REPOSITORY=$(cat "plugin-config.json" | jq -r .Plugins[\"$EXTENSION_NAME\"][\"repository\"])
  EXTENSION_REVISION=$(cat "plugin-config.json" | jq -r .Plugins[\"$EXTENSION_NAME\"][\"revision\"])

  CURRENT_REVISION=$(git ls-remote --tags --refs --sort='version:refname' $EXTENSION_REPOSITORY | tail --lines=1 | cut -d/ -f3)
  #Special Cases
  #ms-toolsai.jupyter is hard set for now (also versions are weird)
  if [[ $EXTENSION_NAME = "dbaeumer.vscode-eslint" ]]; then
    CURRENT_REVISION=$(git ls-remote --tags --refs $EXTENSION_REPOSITORY release* | tail --lines=1 | cut -d/ -f3,4)
  fi
  if [[ $EXTENSION_NAME = "llvm-vs-code-extensions.vscode-clangd" || $EXTENSION_NAME = "muhammad-sammy.csharp" ]]; then
    CURRENT_REVISION=$(git ls-remote --tags --refs --sort='version:refname' $EXTENSION_REPOSITORY | grep -v 'v' | tail --lines=1 | cut -d/ -f3)
  fi
  if [[ $EXTENSION_NAME = "redhat.vscode-xml" ]]; then
    CURRENT_REVISION=$(git ls-remote --tags --refs --sort='version:refname' $EXTENSION_REPOSITORY | grep -v -e 'v' -e 'latest' | tail --lines=1 | cut -d/ -f3)
  fi
  if [[ $EXTENSION_NAME = "redhat.fabric8-analytics" ]]; then
    CURRENT_REVISION=$(git ls-remote --tags --refs --sort='version:refname' $EXTENSION_REPOSITORY | grep -v '2019' | tail --lines=1 | cut -d/ -f3)
  fi
  if [[ $EXTENSION_NAME = "ms-vscode.js-debug" ]]; then
    CURRENT_REVISION=$(git ls-remote --tags --refs --sort='version:refname' $EXTENSION_REPOSITORY | grep -v '2020' | tail --lines=1 | cut -d/ -f3)
  fi
  if [[ $EXTENSION_NAME = "ms-python.python" ]]; then
    CURRENT_REVISION=$(git ls-remote --tags --refs --sort='version:refname' $EXTENSION_REPOSITORY 20* | tail --lines=1 | cut -d/ -f3)
  fi
  if [[ $CURRENT_REVISION = "" ]]; then
    CURRENT_REVISION=$(git ls-remote $EXTENSION_REPOSITORY HEAD)
    CURRENT_REVISION=${CURRENT_REVISION:0:40}
  fi

  if [[ $CURRENT_REVISION != $EXTENSION_REVISION ]]; then
    FILE=$(cat "plugin-config.json" | jq -r ".Plugins[\"$EXTENSION_NAME\"][\"revision\"] |= \"$CURRENT_REVISION\"")
    echo "${FILE}" > "plugin-config.json"

    UPDATES=$UPDATES$EXTENSION_NAME$'\n'
  fi

done

echo "$UPDATES"
