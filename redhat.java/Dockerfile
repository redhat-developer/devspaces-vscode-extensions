#
# Copyright (c) 2020-2023 Red Hat, Inc.
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

USER root
WORKDIR /

ENV JDT_VERSION="v1.23.0"

RUN npm install -g ${extension_manager}

RUN mkdir ./${extension_name}-src && cd ./${extension_name}-src && \
    #clone eclipse.jdt.ls
    git clone https://github.com/eclipse/eclipse.jdt.ls && \
    cd eclipse.jdt.ls && git checkout ${JDT_VERSION} && \
    rm -rf ./.git && tar -czvf /eclipse.jdt.ls-${JDT_VERSION}-sources.tar.gz ./ && \
    cd .. && \
    git clone ${extension_repository} ${extension_name} && \
    cd ./${extension_name} && git checkout ${extension_revision} && \
    #Copy quarkus source into extension source to package both
    cp /eclipse.jdt.ls-${JDT_VERSION}-sources.tar.gz ./ && \
    rm -rf ./.git && tar -czvf /${extension_name}-sources.tar.gz ./ && \
    npm install -g @vscode/vsce@${extension_vsce} gulp-cli@2.3.0 && \
    if [[ -f yarn.lock ]]; then yarn install; \
    else npm install --unsafe-perm=true --allow-root; fi && \
    npm run compile && \
    npm run vscode:prepublish && \
    vsce package --out /${extension_name}.vsix
