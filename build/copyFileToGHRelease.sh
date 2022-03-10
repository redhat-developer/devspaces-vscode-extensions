#!/bin/bash
#
# Copyright (c) 2022 Red Hat, Inc.
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

usage () {
    echo "
Usage:

  $0 https://url/1.vsix [https://url/2.vsix ...]
"
}
GITHUB_REPO="redhat-developer/codeready-workspaces-vscode-extensions"
MIDSTM_BRANCH="main"
ASSET_VERSION="7.44" # or 3.0
ASSET_NAME="che" # or devspaces
PRE_RELEASE=""

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
if [[ -z $URLList ]]; then echo "Error: no URLs specified to publish!"; usage; exit 1; fi

for URL in ${URLList}; do
  curl -sSLO $URL
  fileToPush=${URL##*/}
  if [[ ! $(hub release | grep ${ASSET_VERSION}-${ASSET_NAME}-assets) ]]; then
    #no existing release, create it
    hub release create -t "${MIDSTM_BRANCH}" \
      -m "${ASSET_VERSION} ${ASSET_NAME} vsix files" -m "vscode extensions for ${ASSET_VERSION}" \
      ${PRE_RELEASE} "${ASSET_VERSION}-${ASSET_NAME}-assets"
  fi

  echo "[INFO] Upload new asset $fileToPush (1/3)"
  try=$(hub release edit -a ${fileToPush} "${ASSET_VERSION}-${ASSET_NAME}-assets" \
    -m "${ASSET_VERSION} ${ASSET_NAME} vsix files" -m "vscode extensions for ${ASSET_VERSION}" 2>&1 || true)
  echo "[INFO] $try"

  # if release doesn't exist, create it
  if [[ $try == *"nable to find release with tag name"* ]]; then
    echo "[WARNING] GH release '${ASSET_VERSION} ${ASSET_NAME} vsix files' does not exist: create it (1)"
    hub release create -t "${MIDSTM_BRANCH}" \
      -m "${ASSET_VERSION} ${ASSET_NAME} vsix files" -m "vscode extensions for ${ASSET_VERSION}" \
      ${PRE_RELEASE} "${ASSET_VERSION}-${ASSET_NAME}-assets" || true
    sleep 10s
    echo "[INFO] Upload new asset $fileToPush (2/3)"
    tryAgain=$(hub release edit -a ${fileToPush} "${ASSET_VERSION}-${ASSET_NAME}-assets" \
    -m "${ASSET_VERSION} ${ASSET_NAME} vsix files" -m "vscode extensions for ${ASSET_VERSION}" 2>&1 || true)
    echo "[INFO] $tryAgain"
  fi
  # if release STILL doesn't exist, create it again (?)
  if [[ $tryAgain == *"nable to find release with tag name"* ]]; then
    echo "GH release '${ASSET_VERSION} ${ASSET_NAME} vsix files' does not exist: create it (2)"
    hub release create -t "${MIDSTM_BRANCH}" \
      -m "${ASSET_VERSION} ${ASSET_NAME} vsix files" -m "vscode extensions for ${ASSET_VERSION}" \
      ${PRE_RELEASE} "${ASSET_VERSION}-${ASSET_NAME}-assets" || true
    sleep 10s
    echo "[INFO] Upload new asset $fileToPush (3/3)"
    hub release edit -a ${fileToPush} "${ASSET_VERSION}-${ASSET_NAME}-assets" \
    -m "${ASSET_VERSION} ${ASSET_NAME} vsix files" -m "vscode extensions for ${ASSET_VERSION}" || \
    { echo "[ERROR] Failed to push ${fileToPush} to '${ASSET_VERSION}-${ASSET_NAME}-assets' release!"; exit 1; }
  fi

  # cleanup downloaded files
  rm -f $fileToPush
done
