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

USER 1001
WORKDIR ${HOME}

RUN npm install -g ${extension_manager}

# build bug - if project path contain dots, it will cause one of dependencies to fail build:
# https://github.com/redhat-developer/vscode-openshift-tools/issues/3527
# since `extension_name` contains one, a `workaround_path` variable will be used
# once the bug is fixed, workaround path can be replaced back with extension_name
ENV workaround_path="vscode-openshift-connector"
RUN mkdir ./${workaround_path}-src && cd ./${workaround_path}-src && \
    git clone ${extension_repository} ${workaround_path} && \
    cd ./${workaround_path} && git checkout ${extension_revision} && \
    rm -rf ./.git && tar -czvf ${HOME}/${extension_name}-sources.tar.gz ./ && \
    npm install -g @vscode/vsce@${extension_vsce} gulp-cli@2.3.0 && \
    if [[ -f yarn.lock ]]; then yarn install; \
    else npm install --unsafe-perm=true --allow-root; fi && \
    vsce package --out ${HOME}/${extension_name}.vsix

USER root

RUN mv ${HOME}/${extension_name}-sources.tar.gz / && \
    mv ${HOME}/${extension_name}.vsix / 
