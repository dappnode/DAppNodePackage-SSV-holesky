ARG DGK_UPSTREAM_VERSION

FROM bloxstaking/ssv-dkg:${DGK_UPSTREAM_VERSION}

RUN apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community yq

COPY dkg-config.yml /data/dkg/config/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENV DKG_PORT=14515 \
    DKG_DATA_DIR=/data/dkg \
    OPERATOR_DATA_DIR=/data/operator \
    NETWORK=holesky \
    METRICS_PORT=15000

ENTRYPOINT [ "entrypoint.sh" ]