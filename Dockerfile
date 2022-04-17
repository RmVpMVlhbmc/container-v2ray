FROM golang:alpine AS builder

ARG VERSION

RUN set -ex && apk add gcc musl-dev && cd / \
    && wget -O - "https://github.com/SagerNet/v2ray-core/archive/$VERSION.tar.gz" | tar xzf -
RUN set -ex && cd /v2ray-core-*/ \
    && go build -v -o /usr/bin/v2ray -trimpath -ldflags "-s -w -buildid=" ./main


FROM alpine:latest

ENV V2RAY_LOCATION_ASSET /usr/local/share/v2ray

LABEL org.opencontainers.image.authors "Fei Yang <projects@feiyang.moe>"
LABEL org.opencontainers.image.url https://github.com/RmVpMVlhbmc/container-v2ray
LABEL org.opencontainers.image.documentation https://github.com/RmVpMVlhbmc/container-v2ray/blob/main/README.md
LABEL org.opencontainers.image.source https://github.com/RmVpMVlhbmc/container-v2ray
LABEL org.opencontainers.image.vendor "FeiYang Labs"
LABEL org.opencontainers.image.licenses GPL-3.0-only
LABEL org.opencontainers.image.title V2Ray-SN
LABEL org.opencontainers.image.description "Minimalistic SagerNet specialized v2ray container image based on Apline linux."

RUN set -ex && mkdir -p /config /data /usr/local/share/v2ray \
    && wget -O /usr/local/share/v2ray/geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat \
    && wget -O /usr/local/share/v2ray/geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat

COPY --from=builder /usr/bin/v2ray /usr/bin/v2ray

VOLUME ["/config", "/data"]

WORKDIR /config

CMD ["/usr/bin/v2ray", "run", "-c", "config.json"]
