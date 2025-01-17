FROM golang:latest AS builder
WORKDIR /app

FROM ubuntu
WORKDIR /app

ARG DEBIAN_FRONTEND=noninteractive

# https://tailscale.com/kb/1118/custom-derp-servers/
# https://tailscale.com/kb/1031/install-linux
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y ca-certificates && \
    mkdir /app/certs && \
    go install tailscale.com/cmd/derper@main && \
    curl -fsSL https://tailscale.com/install.sh | sh

ENV DERP_DOMAIN your-hostname.com
ENV DERP_CERT_MODE letsencrypt
ENV DERP_CERT_DIR /app/certs
ENV DERP_ADDR :443
ENV DERP_STUN true
ENV DERP_STUN_PORT 3478
ENV DERP_HTTP_PORT 80
ENV DERP_VERIFY_CLIENTS false

COPY --from=builder /go/bin/derper .

CMD /app/derper --hostname=$DERP_DOMAIN \
    --certmode=$DERP_CERT_MODE \
    --certdir=$DERP_CERT_DIR \
    --a=$DERP_ADDR \
    --stun=$DERP_STUN  \
    --stun-port=$DERP_STUN_PORT \
    --http-port=$DERP_HTTP_PORT \
    --verify-clients=$DERP_VERIFY_CLIENTS

