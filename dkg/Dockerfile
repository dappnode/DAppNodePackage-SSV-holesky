ARG DGK_UPSTREAM_VERSION

FROM bloxstaking/ssv-dkg:v2.1.0

RUN apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
    yq inotify-tools jq curl

RUN mkdir -p /ssl

# Generate a self-signed SSL certificate
RUN openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
  -keyout /ssl/tls.key -out /ssl/tls.crt \
  -subj "/C=CN/ST=GD/L=SZ/O=ssv, Inc./CN=*.ssv.com"

COPY dkg-config.yml /ssv-dkg/config/dkg-config.yml
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENV DKG_PORT=14515 \
    DKG_DATA_DIR=/data/dkg \
    OPERATOR_DATA_DIR=/data/operator \
    NETWORK=holesky \
    METRICS_PORT=15000 \
    DKG_CONFIG_DIR=/ssv-dkg/config

ENTRYPOINT [ "entrypoint.sh" ]