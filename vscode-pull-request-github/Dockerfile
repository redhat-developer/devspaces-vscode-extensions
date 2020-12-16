#
# Copyright (c) 2020 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

FROM registry.access.redhat.com/ubi8/nodejs-12

ARG extension_repository
ARG extension_revision
ARG extension_name

USER root
WORKDIR /

RUN dnf install -y python36 python3-six python3-pip platform-python-pip libsecret curl

RUN mkdir ./${extension_name}-src && cd ./${extension_name}-src && \
    git clone ${extension_repository} ${extension_name} && \
    cd ./${extension_name} && git checkout ${extension_revision} && \
    rm -rf ./.git && tar -czvf /${extension_name}-${extension_revision}-sources.tar.gz ./ && \
    npm install -g yarn vsce gulp-cli && yarn && yarn install && \
    vsce package --out /${extension_name}-${extension_revision}.vsix