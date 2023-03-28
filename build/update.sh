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

PLUGINS=$(ls)
UPDATES=""

for EXTENSION_NAME in $PLUGINS
do
  if test -f "$EXTENSION_NAME/extension.json"; then
    EXTENSION_JSON="$EXTENSION_NAME/extension.json"

    echo "EXTENSION_JSON: $EXTENSION_JSON"

    EXTENSION_REPOSITORY=$(cat "$EXTENSION_JSON" | jq -r .repository)
    EXTENSION_REVISION=$(cat "$EXTENSION_JSON" | jq -r .revision)

    CURRENT_REVISION=$(git ls-remote $EXTENSION_REPOSITORY HEAD)
    CURRENT_REVISION=${CURRENT_REVISION:0:40}

    echo $CURRENT_REVISION

    if [[ $CURRENT_REVISION != $EXTENSION_REVISION ]]; then
      FILE=$(cat $EXTENSION_JSON | jq -r .revision' |= '"\"$CURRENT_REVISION\"")
      echo "$FILE" > $EXTENSION_JSON

      UPDATES="$UPDATES$EXTENSION_NAME "
    fi
  fi

echo $UPDATES > updates.txt

done



