#!/bin/bash
#
# Copyright (c) 2023 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Checks the Visual Studio extension for updates and returns true if it finds changes so the 
# jenkins job knows to build the plugin.

set -e

EXTENSION_NAME=$1

UPDATE=$(cat "plugin-config.json" | jq -r .Plugins[\"$EXTENSION_NAME\"][\"update\"])

if [ "$UPDATE" = "false" ]; then 
  echo "false"
  exit 
fi

EXTENSION_REPOSITORY=$(cat "plugin-config.json" | jq -r .Plugins[\"$EXTENSION_NAME\"][\"repository\"])
EXTENSION_REVISION=$(cat "plugin-config.json" | jq -r .Plugins[\"$EXTENSION_NAME\"][\"revision\"])

CURRENT_REVISION=$(git ls-remote $EXTENSION_REPOSITORY HEAD)
CURRENT_REVISION=${CURRENT_REVISION:0:40}

if [[ $CURRENT_REVISION != $EXTENSION_REVISION ]]; then
  FILE=$(cat "plugin-config.json" | jq -r ".Plugins[\"$EXTENSION_NAME\"][\"revision\"] |= \"$CURRENT_REVISION\"")
  echo "${FILE}" > "plugin-config.json"

  echo "true"
fi

echo "false"
