#!/bin/bash
set -euo pipefail

echo "Memulai deploy Prokura API..."

cd "$(dirname "$0")"

if [ ! -f .env.prokura-api ]; then
  echo "File .env.prokura-api belum ada."
  echo "   Buat file tersebut dari template deployment sebelum menjalankan deploy."
  exit 1
fi

set -a
. ./.env.prokura-api
set +a

git pull origin main

docker compose --env-file .env.prokura-api -f docker-compose.vps-api.yml up -d --build
docker image prune -f

echo "Prokura API berhasil dideploy."
echo "   Local health: http://127.0.0.1:${PROKURA_API_HOST_PORT:-3011}/api/health"
