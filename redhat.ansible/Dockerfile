#
# Copyright (c) 2024 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

ARG extension_image

FROM registry.access.redhat.com/ubi8/nodejs-20:1-38.1712567745

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
    npm install -g @vscode/vsce@${extension_vsce} gulp-cli@2.3.0 && \
    yarn install && \
    yarn run clean && \
    yarn run als-compile && \
    yarn run compile && \
    npx tsc -p ./ && \
    mkdir out/log && touch out/log/package.log && \
    ./tools/package.sh && \
    mv ansible-*.vsix /${extension_name}.vsix && \
    rm -rf ./.git && tar -czvf /${extension_name}-sources.tar.gz ./
