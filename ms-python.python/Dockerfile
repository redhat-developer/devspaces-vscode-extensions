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

RUN npm install -g ${extension_manager}
RUN dnf -y install python36 python3-six python3-pip platform-python-pip 
RUN /usr/bin/python3 -m pip install --upgrade pip

# activating CI/production mode to reduce size of webpack output
ENV TRAVIS=true

RUN mkdir ./${extension_name}-src && cd ./${extension_name}-src && \
    git clone ${extension_repository} ${extension_name} && \
    cd ./${extension_name} && git checkout ${extension_revision} && \
    npm install -g @vscode/vsce@${extension_vsce} gulp-cli@2.3.0 && \
    if [[ -f yarn.lock ]]; then yarn install; \
    else npm install --unsafe-perm=true --allow-root; fi && \
    rm -rf ./.git && tar -czvf /${extension_name}-sources.tar.gz ./ && \
    gulp clean && gulp prePublishBundle && \
    vsce package --out /${extension_name}.vsix
