#
# Copyright (c) 2020 Red Hat, Inc.
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

ENV QUARKUS_VERSION="0.14.1"

RUN npm install -g ${extension_manager}

RUN mkdir ./${extension_name}-src && cd ./${extension_name}-src && \
    #clone quarkus first
    git clone https://github.com/redhat-developer/quarkus-ls && \
    cd quarkus-ls && git checkout ${QUARKUS_VERSION} && \
    rm -rf ./.git && tar -czvf /quarkus-ls-${QUARKUS_VERSION}-sources.tar.gz ./ && \
    cd .. && \
    git clone ${extension_repository} ${extension_name} && \
    cd ./${extension_name} && git checkout ${extension_revision} && \
    #Copy quarkus source into extension source to package both
    cp /quarkus-ls-${QUARKUS_VERSION}-sources.tar.gz ./ && \
    npm install -g @vscode/vsce@${extension_vsce} gulp-cli@2.3.0 --unsafe-perm=true && \
    if [[ -f yarn.lock ]]; then yarn install; \
    else npm install --unsafe-perm=true --allow-root; fi && \
    rm -rf ./.git && tar -czvf /${extension_name}-sources.tar.gz ./ && \
    vsce package --out /${extension_name}.vsix
