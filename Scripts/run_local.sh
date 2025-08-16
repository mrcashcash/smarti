#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BACKEND="$ROOT/smarti-backend"
FRONTEND="$ROOT/smarti-frontend"

echo "Project root: $ROOT"
echo

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

MISSING=
for cmd in php composer node npm; do
  if ! command_exists "$cmd"; then
    MISSING="$MISSING $cmd"
  fi
done

if [ -n "${MISSING}" ]; then
  echo "Missing required commands:${MISSING}"
  echo "Install them and re-run the script."
  exit 1
fi

echo "=> Setting up backend ($BACKEND)..."
cd "$BACKEND"

if [ ! -d "vendor" ]; then
  echo "Running composer install..."
  composer install --no-interaction --prefer-dist
else
  echo "composer vendor directory exists, skipping composer install."
fi

if [ ! -f ".env" ]; then
  echo "Copying .env.example to .env"
  cp .env.example .env
else
  echo ".env already exists"
fi

if [ ! -d "database" ]; then
  mkdir -p database
fi

if [ ! -f "database/database.sqlite" ]; then
  echo "Creating SQLite database file"
  touch database/database.sqlite
else
  echo "SQLite file exists"
fi

if [ -f "package.json" ]; then
  if [ ! -d "node_modules" ]; then
    echo "Installing backend npm dependencies..."
    npm install
  else
    echo "backend node_modules exists, skipping npm install."
  fi
fi

# Generate APP_KEY if missing
if ! grep -q "^APP_KEY=" .env || [ -z "$(grep '^APP_KEY=' .env | cut -d= -f2)" ]; then
  echo "Generating APP_KEY..."
  php artisan key:generate --ansi
fi
php artisan config:cache || true
php artisan route:cache || true

echo "Running migrations..."
php artisan migrate --force --quiet

# Start Laravel backend
echo "Starting Laravel backend (http://127.0.0.1:8000)..."
php artisan serve --host=127.0.0.1 --port=8000 >/dev/null 2>&1 &

BACKEND_PID=$!

# Frontend setup
echo
echo "=> Setting up frontend ($FRONTEND)..."
cd "$FRONTEND"

if [ ! -d "node_modules" ]; then
  echo "Installing frontend npm dependencies..."
  npm install
else
  echo "frontend node_modules exists, skipping npm install."
fi

echo "Starting Angular dev server (http://localhost:4200)..."
npm start >/dev/null 2>&1 &

FRONTEND_PID=$!

echo
echo "Backend PID: $BACKEND_PID"
echo "Frontend PID: $FRONTEND_PID"
echo
echo "Waiting for processes. Press Ctrl+C to stop."

# Wait for background processes
wait $BACKEND_PID $FRONTEND_PID
