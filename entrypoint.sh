#!/usr/bin/env bash
set -euo pipefail

: "${PUID:=12200}"
: "${PGID:=12200}"
: "${MONERO_DATA:=/data}"
: "${MONERO_CONF:=/etc/monero/bitmonero.conf}"

if ! getent group monero >/dev/null; then
	addgroup --gid "$PGID" monero || true
fi

if ! id monero >/dev/null 2>&1; then
	adduser --disabled-password --gecos "" --uid "$PUID" --gid "$PGID" -s /usr/sbin/nologin monero || true
fi

mkdir -p "$MONERO_DATA" || true
chown -R monero:monero "$MONERO_DATA" || true
chmod -R 700 "$MONERO_DATA" || true

if [[ "${1:-}" == "monerod" ]]; then
  exec gosu monero "$@" --non-interactive --config-file="$MONERO_CONF" --data-dir="$MONERO_DATA"
fi

exec gosu monero "$@"
