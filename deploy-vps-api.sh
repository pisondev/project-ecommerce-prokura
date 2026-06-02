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

docker compose --env-file .env.prokura-api -f docker-compose.vps-api.yml up -d --build --remove-orphans
docker image prune -f

echo "Prokura stack berhasil dideploy."
echo "   API gateway:      http://127.0.0.1:${PROKURA_API_GATEWAY_HOST_PORT:-5010}/api/health"
echo "   Catalog health:   http://127.0.0.1:${PROKURA_CATALOG_HOST_PORT:-5101}/health"
echo "   Inventory health: http://127.0.0.1:${PROKURA_INVENTORY_HOST_PORT:-5102}/health"
echo "   Customer health:  http://127.0.0.1:${PROKURA_CUSTOMER_HOST_PORT:-5103}/health"
echo "   Order health:     http://127.0.0.1:${PROKURA_ORDER_HOST_PORT:-5104}/health"
echo "   Reporting health: http://127.0.0.1:${PROKURA_REPORTING_HOST_PORT:-5105}/health"
echo "   Customer web:     http://127.0.0.1:${PROKURA_WEB_HOST_PORT:-3011}"
echo "   Admin web:        http://127.0.0.1:${PROKURA_ADMIN_HOST_PORT:-8501}/_stcore/health"
