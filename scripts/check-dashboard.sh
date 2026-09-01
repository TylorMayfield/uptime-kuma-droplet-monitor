#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f .env ]]; then
  echo "Copy .env.example to .env first." >&2
  exit 1
fi

set -a
. ./.env
set +a

docker compose ps
curl --fail --silent --show-error --max-time 15 "https://$KUMA_DOMAIN" >/dev/null
printf 'Dashboard responds at https://%s. Finish setup in the browser, then test a monitor and its notification.\n' "$KUMA_DOMAIN"
