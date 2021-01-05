#
# Copyright (c) 2020 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

FROM registry.access.redhat.com/ubi8/nodejs-10

ARG extension_repository
ARG extension_revision
ARG extension_name

USER root
WORKDIR /

RUN dnf -y install git python36 python3-six python3-pip platform-python-pip \
    curl bzip2 gdb make cmake gcc gcc-c++ libsecret
RUN /usr/bin/python3 -m pip install --upgrade pip
RUN mkdir ./${extension_name}-src && cd ./${extension_name}-src && \
    git clone ${extension_repository} ${extension_name} && \
    cd ./${extension_name} && git checkout ${extension_revision} && \
    rm -rf ./.git && tar -czvf /${extension_name}-${extension_revision}-sources.tar.gz ./ && \
    npm install -g vsce yarn@1.16.0 && yarn install && \
    curl https://raw.githubusercontent.com/microsoft/vscode/1.48.0/src/vs/vscode.d.ts > $(pwd)/src/typings/vscode.d.ts && \
    curl https://raw.githubusercontent.com/microsoft/vscode/1.48.0/src/vs/vscode.proposed.d.ts > $(pwd)/src/typings/vscode.proposed.d.ts && \
    vsce package --out /${extension_name}-${extension_revision}.vsix
