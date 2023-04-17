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

# Make cmake so we can make zeromq so we can install npm dependencies
RUN curl -L https://github.com/Kitware/CMake/releases/download/v3.26.2/cmake-3.26.2.tar.gz -o cmake-3.26.2.tar.gz && \
    gunzip cmake-3.26.2.tar.gz && \
    tar -xvf cmake-3.26.2.tar && \
    cd cmake-3.26.2 && \
    ./bootstrap && \
    make && \
    make install 

RUN npm install -g ${extension_manager}
RUN dnf -y install python38 python3-pip platform-python-pip && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    python3 -m pip install --upgrade pip

RUN mkdir ./${extension_name}-src && cd ./${extension_name}-src && \
    git clone ${extension_repository} ${extension_name} && \
    cd ./${extension_name} && git checkout ${extension_revision} && \
    rm -rf ./.git && tar -czvf /${extension_name}-sources.tar.gz ./ && \
    npm install -g @vscode/vsce@${extension_vsce} gulp-cli@2.3.0 && \
    npm install zeromq@6.0.0-beta.6 && \
    npm install  --unsafe-perm=true --allow-root --ignore-scripts && \
#--loglevel silly
    python3 -m pip --disable-pip-version-check install -t ./pythonFiles/lib/python --no-cache-dir \
     --implementation py --no-deps --upgrade -r ./requirements.txt --no-user && \
    npm run clean && \
    npm run package


