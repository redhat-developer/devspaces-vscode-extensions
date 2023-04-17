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
