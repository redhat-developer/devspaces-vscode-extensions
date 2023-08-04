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

RUN npm install -g ${extension_manager}

RUN mkdir ./${extension_name}-src && cd ./${extension_name}-src && \
    git clone ${extension_repository} ${extension_name} && \
    cd ./${extension_name} && git checkout ${extension_revision} && \
    npm install -g @vscode/vsce@${extension_vsce} gulp-cli@2.3.0 --unsafe-perm=true&& \
    npm install --unsafe-perm=true --allow-root && \
    dnf module install -y nodejs:16/common && \
    npm install @types/vscode react-is crypto --unsafe-perm=true && \
    rm -rf ./.git && tar -czvf /${extension_name}-sources.tar.gz ./ && \
    #npm run package
    gulp clean && gulp prePublishBundle && vsce package -o /${extension_name}.vsix
