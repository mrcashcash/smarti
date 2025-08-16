#!/bin/sh
set -e

cd /app || exit 1

echo "[entrypoint] Starting backend setup..."

mkdir -p database &

if [ ! -f vendor/autoload.php ]; then
  echo "[entrypoint] Installing composer dependencies..."
  composer install --no-interaction --prefer-dist --optimize-autoloader
else
  echo "[entrypoint] Vendor present, checking for updates..."
  composer install --no-interaction --prefer-dist --optimize-autoloader
fi

# Wait for database creation to complete
wait

# Create SQLite database if missing
if [ ! -f database/database.sqlite ]; then
  echo "[entrypoint] Creating SQLite database file"
  touch database/database.sqlite
  chmod 664 database/database.sqlite
fi

cp .env.example .env

# Generate APP_KEY if not present
if [ -z "${APP_KEY}" ] || [ "${APP_KEY}" = "base64:" ]; then
  echo "[entrypoint] Generating APP_KEY"
  php artisan key:generate --force
fi

# Run migrations
echo "[entrypoint] Running migrations"
php artisan migrate --force

# Cache routes and config for better performance
echo "[entrypoint] Optimizing Laravel..."
php artisan config:cache || true
php artisan route:cache || true

echo "[entrypoint] Backend ready! Starting server..."

# Execute the container's CMD
exec "$@"
