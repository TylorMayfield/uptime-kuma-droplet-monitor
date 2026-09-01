#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "Install Docker before running this check." >&2
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "Docker Compose v2 is required." >&2
  exit 1
fi

if [[ ! -f .env ]]; then
  echo "Copy .env.example to .env, then set KUMA_DOMAIN." >&2
  exit 1
fi

set -a
. ./.env
set +a

if [[ -z "${KUMA_DOMAIN:-}" || "$KUMA_DOMAIN" == "status.example.com" ]]; then
  echo "Set KUMA_DOMAIN in .env to a real DNS name." >&2
  exit 1
fi

docker compose config -q
printf 'Compose configuration is valid for %s. Confirm its DNS A/AAAA records point to this Droplet before starting Caddy.\n' "$KUMA_DOMAIN"
