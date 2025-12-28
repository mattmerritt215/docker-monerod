FROM debian:bookworm-slim

ARG MONERO_VERSION=0.18.4.4
ARG TARGETARCH
ARG UID=12200
ARG GID=12200

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
	ca-certificates \
	curl \
	bzip2 \
	gosu; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    arch="linux-x64"; \
    url="https://downloads.getmonero.org/cli/monero-linux-x64-v0.18.4.4.tar.bz2"; \
    curl -fsSLo /tmp/monero.tar.bz2 "$url"; \
    mkdir -p /opt/monero; \
    tar -xjf /tmp/monero.tar.bz2 -C /opt/monero --strip-components=1; \
    rm -f /tmp/monero.tar.bz2; \
    ln -s /opt/monero/monerod /usr/local/bin/monerod; \
    ln -s /opt/monero/monero-wallet-rpc /usr/local/bin/monero-wallet-rpc; \
    monerod --version

RUN useradd -m -u 12200 -s /usr/sbin/nologin monero

ENV MONERO_DATA=/data
VOLUME ["/data"]

COPY entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 18080 18081 18082
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

