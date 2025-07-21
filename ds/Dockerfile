FROM ghcr.io/zen-leow/pingds:8.0.0

USER forgerock
ARG target=/opt/opendj

COPY --chown=forgerock:root scripts ${target}/scripts

WORKDIR ${target}
RUN scripts/setup && scripts/post-init && rm scripts/setup scripts/post-init