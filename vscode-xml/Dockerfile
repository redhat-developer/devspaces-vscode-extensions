#
# Copyright (c) 2020 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

# https://catalog.redhat.com/software/containers/ubi8/nodejs-12/5d3fff015a13461f5fb8635a?tag=1-70
FROM registry.access.redhat.com/ubi8/nodejs-12:1-70

ARG extension_repository
ARG extension_revision
ARG extension_name

ENV XML_SERVER_URL=https://repo.eclipse.org/content/repositories/lemminx-releases/org/eclipse/lemminx/org.eclipse.lemminx

USER root
WORKDIR /

RUN dnf install -y jq

RUN mkdir ./${extension_name}-src && cd ./${extension_name}-src && \
    git clone ${extension_repository} ${extension_name} && \
    cd ./${extension_name} && git checkout ${extension_revision} && \
    rm -rf ./.git && tar -czvf /${extension_name}-${extension_revision}-sources.tar.gz ./ && \
    npm install -g vsce gulp-cli && npm install --unsafe-perm=true --allow-root && \
    export XML_SERVER_VERSION="$(cat package.json | jq -r .xmlServer.version)" && \
    mkdir ./server && cd ./server && export XML_SERVER_FILE=org.eclipse.lemminx-${XML_SERVER_VERSION}-uber.jar && \
    curl ${XML_SERVER_URL}/${XML_SERVER_VERSION}/${XML_SERVER_FILE} -o ${XML_SERVER_FILE} && \
    cd .. && vsce package --out /${extension_name}-${extension_revision}.vsix
