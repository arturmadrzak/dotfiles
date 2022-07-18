#
# Copyright (C) 2022 Artur Mądrzak <artur@madrzak.eu>
#

FROM ubuntu:20.04

LABEL maintainer="Artur Mądrzak <artur@madrzak.eu>"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]


# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        bash \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


ENTRYPOINT ["/bin/bash"]

