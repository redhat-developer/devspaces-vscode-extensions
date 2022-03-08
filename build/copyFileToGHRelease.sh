#!/bin/bash
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation
#
# script to copy some binary from download.jboss.org to https://github.com/redhat-developer/codeready-workspaces-vscode-extensions/releases
#
# for example to copy 
# from https://download.jboss.org/jbosstools/vscode/3rdparty/cdt-vscode/cdt-vscode-0.0.7-75cf95.vsix
#   to https://github.com/redhat-developer/codeready-workspaces-vscode-extensions/releases/download/0.0.7-75cf95-cdt-vscode-assets/cdt-vscode-0.0.7-75cf95.vsix

usageGHT() {
    echo 'Setup:

First, export your GITHUB_TOKEN:

  export GITHUB_TOKEN="...github-token..."
'
}

GITHUB_REPO="redhat-developer/codeready-workspaces-vscode-extensions"

while [[ "$#" -gt 0 ]]; do
  case $1 in
    '-v') ASSET_VERSION="$2"; shift 1;;
    '-b') MIDSTM_BRANCH="$2"; shift 1;;
    '-ght') GITHUB_TOKEN="$2"; export GITHUB_TOKEN="${GITHUB_TOKEN}"; shift 1;;
    '-n'|'--asset-name')       ASSET_NAME="$2"; shift 1;;

    '--prerelease')            PRE_RELEASE="$1";; # --prerelease
    '-h'|'--help') usageGHT; exit 0;;
    *) URLList="${URLList} $1";;
  esac
  shift 1
done

if [[ ! "${GITHUB_TOKEN}" ]]; then usageGHT; exit 1; fi

if [[ ! -x /tmp/uploadAssetsToGHRelease.sh ]]; then
    pushd /tmp/ >/dev/null
    curl -sSLO "https://raw.githubusercontent.com/redhat-developer/codeready-workspaces/crw-2-rhel-8/product/uploadAssetsToGHRelease.sh" && \
    chmod +x uploadAssetsToGHRelease.sh
    popd >/dev/null
fi

pushd /tmp >/dev/null
    git clone --depth 1 https://github.com/$GITHUB_REPO --single-branch sources
    pushd /tmp/sources >/dev/null

    for URL in ${URLList}; do
        curl -sSLO $URL
        file=${URL##*/}
        ASSET_VERSION=${file%.vsix}; ASSET_VERSION=$(echo "$ASSET_VERSION" | sed -r -e "s#([a-z-]+)-([0-9a-f.-]+)#\2#")
        ASSET_NAME=${file%.vsix}; ASSET_NAME=$(echo "$ASSET_NAME" | sed -r -e "s#([a-z-]+)-([0-9a-f.-]+)#\1#")

        /tmp/uploadAssetsToGHRelease.sh --publish-assets --release \
            --repo-path . -b "main" \
            -v "${ASSET_VERSION}" --asset-name "${ASSET_NAME}" "${file}"
    done

    popd >/dev/null
popd >/dev/null
