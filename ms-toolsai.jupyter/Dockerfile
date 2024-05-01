#
# Copyright (c) 2024 Red Hat, Inc.
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

RUN npm install -g ${extension_manager}

RUN mkdir ./${extension_name}-src && cd ./${extension_name}-src && \
    git clone ${extension_repository} ${extension_name} && \
    cd ./${extension_name} && git checkout ${extension_revision} && \
    npm install -g @vscode/vsce@${extension_vsce} && \
    npm ci --ignore-scripts --prefer-offline --no-audit && \
    npm install && \
    rm -rf ./.git && tar -czvf /${extension_name}-sources.tar.gz ./ && \
    npm run package && \
    cp ms-toolsai-jupyter-insiders.vsix /${extension_name}.vsix
