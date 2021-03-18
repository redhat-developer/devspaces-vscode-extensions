#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

FROM registry.access.redhat.com/ubi8/nodejs-10 as builder

ARG extension_repository
ARG extension_revision
ARG extension_name

USER root
WORKDIR /

COPY ./build/content_set*.repo /etc/yum.repos.d/

RUN yum -y -q update && \
    yum groupinstall -y "Development Tools" && \
    yum install -y python27 libX11-devel libxkbfile-devel libsecret-devel && \
    npm install -g yarn && \
    ln /usr/bin/python2 /usr/bin/python

FROM builder

ARG extension_repository
ARG extension_revision
ARG extension_name

COPY ./build/build-vsx.sh /
RUN chmod +x /build-vsx.sh

RUN /build-vsx.sh "${extension_name}" "${extension_repository}" "${extension_revision}"
