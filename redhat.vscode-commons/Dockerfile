#
# Copyright (c) 2020 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

# https://catalog.redhat.com/software/containers/ubi8/nodejs-14/5ed7887dd70cc50e69c2fabb?tag=1-50
FROM registry.access.redhat.com/ubi8/nodejs-18:1-24

ARG extension_repository
ARG extension_revision
ARG extension_name

USER root
WORKDIR /

RUN npm install -g npm@latest

RUN mkdir ./${extension_name}-src && cd ./${extension_name}-src && \
    git clone ${extension_repository} ${extension_name} && \
    cd ./${extension_name} && git checkout ${extension_revision} && \
    rm -rf ./.git && tar -czvf /${extension_name}-${extension_revision}-sources.tar.gz ./ && \
    npm install -g @vscode/vsce@2.17.0 gulp-cli@2.3.0 && npm install --unsafe-perm=true --allow-root && \
    #the svg file breaks vsce so we take it out until they update the marketplace image
    sed -i '/vscode-commons.svg/d' ./README.md && \
    vsce package --out /${extension_name}-${extension_revision}.vsix
