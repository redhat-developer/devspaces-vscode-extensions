#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

ARG extension_image

FROM registry.access.redhat.com/ubi8/${extension_image}

ARG extension_repository
ARG extension_revision
ARG extension_name
ARG extension_manager
ARG extension_vsce

ENV XML_SERVER_URL=https://repo.eclipse.org/content/repositories/lemminx-releases/org/eclipse/lemminx/org.eclipse.lemminx

USER root
WORKDIR /

RUN npm install -g ${extension_manager}
RUN dnf install -y jq

RUN mkdir ./${extension_name}-src && cd ./${extension_name}-src && \
    git clone ${extension_repository} ${extension_name} && \
    cd ./${extension_name} && git checkout ${extension_revision} && \
    rm -rf ./.git && tar -czvf /${extension_name}-sources.tar.gz ./ && \
    echo ">> REPLACE in package-lock.json" && \
    REPLACE_FROM="https://repository.engineering.redhat.com/nexus/repository/registry.npmjs.org" && \
    REPLACE_TO="https://registry.npmjs.org" && \
    sed -i "s|${REPLACE_FROM}|${REPLACE_TO}|" package-lock.json && \
    npm install -g @vscode/vsce@${extension_vsce} gulp-cli@2.3.0 && \
    if [[ -f yarn.lock ]]; then yarn install; \
    else npm install --unsafe-perm=true --allow-root; fi && \
    echo ">> download XML server" && \
    export XML_SERVER_VERSION="$(cat package.json | jq -r .xmlServer.version)" && \
    mkdir ./server && cd ./server && \
    export XML_SERVER_FILE=org.eclipse.lemminx-${XML_SERVER_VERSION}-uber.jar && \
    curl ${XML_SERVER_URL}/${XML_SERVER_VERSION}/${XML_SERVER_FILE} -o ${XML_SERVER_FILE} && \
    echo "$(sha1sum ${XML_SERVER_FILE})" && \
    cd .. && \
    vsce package --out /${extension_name}.vsix
