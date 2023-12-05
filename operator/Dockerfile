ARG UPSTREAM_VERSION

FROM bloxstaking/ssv-node:${UPSTREAM_VERSION}

RUN apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community yq \
    && apk add --no-cache openssl

COPY node-config.yml /data/operator/config/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENV P2P_TCP_PORT=12515 \ 
    P2P_UDP_PORT=13515 \
    OPERATOR_DATA_DIR=/data/operator \
    NETWORK=holesky \
    METRICS_PORT=15000 

ENTRYPOINT [ "entrypoint.sh" ]