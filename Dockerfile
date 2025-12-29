FROM debian:bookworm-slim

ARG MONERO_VERSION=0.18.4.4
ARG TARGETARCH
ARG UID=12200
ARG GID=12200

ARG MONERO_SHA256_AMD64=7fe45ee9aade429ccdcfcad93b905ba45da5d3b46d2dc8c6d5afc48bd9e7f108
ARG MONERO_SHA256_ARM64=b9daede195a24bdd05bba68cb5cb21e42c2e18b82d4d134850408078a44231c5

ENV MONERO_HOME=/opt/monero
ENV MONERO_DATA=/var/lib/monero
ENV MONERO_CONF=/etc/monero/

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    ca-certificates curl \
    bzip2 gosu; \
    && apt clean &&rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp

RUN set -eux; \
    case "$TARGETARCH" in \
    "amd64") archive="monero-linux-x64-v${MONERO_VERSION}.tar.bz2"; sha="${MONERO_SHA256_AMD64}" ;; \
    "arm64") archive="monero-linux-armv8-v${MONERO_VERSION}.tar.bz2"; sha="${MONERO_SHA256_ARM64}" ;; \
    *) echo "Unsupported architecture: $TARGETARCH" >&2; exit 1 ;; \
    esac; \
    url="https://downloads.getmonero.org/cli/${archive}"; \
    curl -fsSLo /tmp/monero.tar.bz2 "$url"; \
    echo "${sha}  /tmp/monero.tar.bz2" | sha256sum -c -; \ 
    mkdir -p "$MONERO_DATA" "$MONERO_HOME" "$MONERO_CONF"; \
    tar -zjf /tmp/monero.tar.bz2 -C "$MONERO_HOME" --strip-components=1; \
    rm -f /tmp/monero.tar.bz2; \
    mv "$MONERO_HOME/monerod" /usr/local/bin/monerod; \
    mv "$MONERO_HOME/monero-wallet-cli" /usr/local/bin/monero-wallet-cli; \
    mv "$MONERO_HOME/monero-wallet-rpc" /usr/local/bin/monero-wallet-rpc; \
    monerod --version

RUN set -eux; \
    groupadd --gid "${GID}" monero || true; \
    useradd --system --uid "${UID}" --gid "${GID}" --home-dir /var/lib/monero --shell /usr/sbin/nologin monero || true; \
    chown -R monero:monero "$MONERO_DATA" "$MONERO_CONF"

VOLUME ["/var/lib/monero", "/etc/monero"]

COPY entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 18080 18081 18082 18083 18089
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["monerod","--config-file","${MONERO_CONF}/bitmonero.conf"]
