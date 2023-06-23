#!/bin/bash
#
# Copyright (c) 2023 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Runs without arguments to check for updates to the Visual Studio plugins
# listed in plugin-config.json.

set -e

MIDSTM_BRANCH=""
updates=""
new=""

usage()
{
    echo "Usage: $0 -b devspaces-3.y-rhel-8 

-b|--branch     [Optional] Specify a devspaces branch. Will be computed from local git directory if not provided.

Requires:
  - plugin-config.json (redhat-developer/devspaces-vscode-extensions)
  - openvsx-sync.json (redhat-developer/devspaces/dependencies/che-plugin-registry) 
  - download-vsix.sh (redhat-developer/devspaces/dependencies/che-plugin-registry)

They will be downloaded if not found."
    exit
}

# commandline args
while [[ "$#" -gt 0 ]]; do
  case $1 in
    '-b'|'--branch') MIDSTM_BRANCH="$2"; shift 1;;
    '-h'|'--help') usage;;
  esac
  shift 1
done

if [[ ! "${MIDSTM_BRANCH}" ]]; then 
    MIDSTM_BRANCHh="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
    if [[ $MIDSTM_BRANCH != "devspaces-3."*"-rhel-8" ]]; then
        MIDSTM_BRANCH="devspaces-3-rhel-8"
    fi
fi

# Check for openvsx-sync.json, plugin-config.json and download-vsix.sh
if [[ ! -f openvsx-sync.json ]]; then
  curl -sSLO https://raw.githubusercontent.com/redhat-developer/devspaces/$MIDSTM_BRANCH/dependencies/che-plugin-registry/openvsx-sync.json
fi
if [[ ! -f download-vsix.sh ]]; then
  curl -sSLO https://raw.githubusercontent.com/redhat-developer/devspaces/$MIDSTM_BRANCH/dependencies/che-plugin-registry/build/scripts/download_vsix.sh
fi
if [[ ! -f plugin-config.json ]]; then
  curl -sSLO https://raw.githubusercontent.com/redhat-developer/devspaces-vscode-extensions/$MIDSTM_BRANCH/plugin-config.json
fi

replaceField()
{
  updateName="$1"
  updateVal="$2"

  changed=$(cat plugin-config.json | jq ${updateName}' |= '"$updateVal")
  echo "${changed}" > "plugin-config.json"
}

# Update openvsx-sync.json
chmod +x -R *.sh
./download-vsix.sh -b $MIDSTM_BRANCH -j ./openvsx-sync.json --no-download 

# Read in openvsx-sync.sh to get list of pluginregistry plugins
pluginsOVSX=$(cat openvsx-sync.json | jq -r '.[].id')
pluginsConfig=$(cat plugin-config.json | jq -r '.Plugins | keys[]')

for extensionName in $pluginsOVSX
do
  # Names need to be lowercase in plugin-config.json so it can be used as a build variable
  pluginName=${extensionName,,}

  # Is it new (does not exist in plugin-config.json)
  if [[ ! $(echo $pluginsConfig | grep $pluginName) ]]; then 
    new=$new$extensionName$'\n'
    continue
  fi

  # If update = false in plugin-config.json move on to next plugin
  update=$(cat "plugin-config.json" | jq -r .Plugins[\"$pluginName\"][\"update\"])
  if [ "$update" = "false" ]; then continue; fi 

  # If updating we need the revision and ovsx version
  revision=$(cat "plugin-config.json" | jq -r .Plugins[\"$pluginName\"][\"revision\"])
  ovsxVersion=$(cat openvsx-sync.json | jq -r ".[] | select (.id == \"$extensionName\") | .version")

  # Check if version has changed
  if [[ ! $(echo $revision | grep $ovsxVersion) ]]; then

    # All repos that need to use commit SHAs instead of version tags have a comment of the form "Version: x.y.z" with the human readable version
    comment=$(cat "plugin-config.json" | jq -r .Plugins[\"$pluginName\"][\"comment\"])
    if [[ $(echo $comment | grep "Version:") ]]; then
      # Check if version actually changed
      commentVersion=$(echo $comment | cut -d ':' -f2)     
      if [[ $(echo $commentVersion | grep  $ovsxVersion) ]]; then continue; fi

      # If version changed find commit closest to the release date
      # Clone the repo so we can get more metadata about commits and tags (i.e. dates)
      mkdir /tmp/vsix-sources/
      sourceRepo=$(cat "plugin-config.json" | jq -r .Plugins[\"$pluginName\"][\"repository\"])
      git clone $sourceRepo /tmp/vsix-sources/$pluginName
      pushd $(pwd)
      cd /tmp/vsix-sources/$pluginName

      # Get metadata from ovsx so we can compare dates
      publisher=$(echo $pluginName | cut -d '.' -f1)
      name=$(echo $pluginName | cut -d '.' -f2)

      ovsxMetadata=$(curl -sLS "https://open-vsx.org/api/$publisher/$name/latest")
      releaseDate=$(echo "$ovsxMetadata" | jq -r '.timestamp')
      releaseDate=$(date +%s -d $releaseDate) #universal format

      # Get the last commit before the release date
      # Command breakdown: pretty format = author date (%ad) and full commit SHA (%H)
        # date in universal format (need dates to sort by dates)
        # sort to make sure the latest are first
      commit=$(git log --pretty=format:"%ad %H" --date=raw --before "$releaseDate" | sort | tail -n 1)
      commitSHA=$(echo $commit | cut -d ' ' -f3)

      # Go back
      popd

      # Update revision
      replaceField ".Plugins[\"$pluginName\"][\"revision\"]" "\"$commitSHA\""

      # Update comment with new version
      replaceField ".Plugins[\"$pluginName\"][\"comment\"]" "\"Version: $ovsxVersion\""

      # Add to updates list
      updates=$updates$extensionName$'\n'

      # Cleanup and return to original directory
      rm -rf /tmp/vsix-sources/

      continue
    fi

    # If not a special case then grep for the tag with the correct version and use that.
    tag=$(echo $revision | sed s/[0-9].*/$ovsxVersion/)
    replaceField ".Plugins[\"$pluginName\"][\"revision\"]" "\"$tag\""
    # Add to updates list
    updates=$updates$extensionName$'\n'
  fi

done

echo "Updated Extensions:
$updates"
echo "$updates" > updates.txt

if [[ ! "$new" = "" ]]; then
  echo "New Extensions: 
$new"
  echo "$new" > new.txt
fi
