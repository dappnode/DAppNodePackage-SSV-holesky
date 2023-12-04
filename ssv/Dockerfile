ARG UPSTREAM_VERSION

FROM bloxstaking/ssv-node:${UPSTREAM_VERSION}

RUN apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community yq \
    && apk add --no-cache openssl

COPY node-config.yml dkg-config.yml /ssv-operator/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENV P2P_TCP_PORT=12515 P2P_UDP_PORT=13515 DKG_PORT=14515 \
    SSV_ROOT_DIR=/ssv-operator DATA_PATH=/data \
    NETWORK=holesky METRICS_PORT=15000 

RUN mkdir -p /ssv-operator

ENTRYPOINT [ "entrypoint.sh" ]