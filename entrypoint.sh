#!/usr/bin/env bash
set -euo pipefail

: "${MONERO_DATA:=/var/lib/monero}"

if [ "${1:-}" != "" ] && [ "${1#-}" != "$1" ]; then
	set -- monerod "$@"
fi

if [ "$(id -u)" = "0" ]; then
	mkdir -p "$MONERO_DATA"
	chown -R monero:monero "$MONERO_DATA" 2>/dev/null || true

	case "${1:-}" in
		monerod|monero-wallet-rpc|monero-wallet-cli)
			exec gosu monero "$@"
			;;
		*)
			exec "$@"
			;;
	esac
fi

exec "$@"


