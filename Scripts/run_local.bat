@echo off
REM Run the project locally (not using Docker) on Windows
REM - Installs backend/frontend dependencies if missing
REM - Ensures .env and sqlite DB exist
REM - Runs migrations, storage link, and caching
REM - Starts Laravel backend and Angular frontend in new windows
REM
REM Usage: Scripts\run_local.bat

setlocal

REM Resolve project root (directory above the one this script is in)
set "ROOT=%~dp0.."
pushd "%ROOT%"
for %%I in ("%CD%") do set "ROOT=%%~fI"
popd

set "BACKEND=%ROOT%\smarti-backend"
set "FRONTEND=%ROOT%\smarti-frontend"

echo Project root: %ROOT%
echo.

REM -----------------------------
REM Prerequisite Check
REM -----------------------------
echo => Checking for required tools (php, composer, node, npm)...
where php >nul 2>&1 || (set "MISSING=%MISSING% php")
where composer >nul 2>&1 || (set "MISSING=%MISSING% composer")
where node >nul 2>&1 || (set "MISSING=%MISSING% node")
where npm >nul 2>&1 || (set "MISSING=%MISSING% npm")

if defined MISSING (
  echo Missing required commands:%MISSING%
  echo Please install them and ensure they are in your system's PATH.
  exit /b 1
)
echo All tools found.
echo.


REM -----------------------------
REM Backend Setup
REM -----------------------------
echo => Setting up backend (%BACKEND%)...
pushd "%BACKEND%"

REM Install Composer dependencies
if not exist "vendor\autoload.php" (
  echo Running composer install...
  composer install --no-interaction --prefer-dist
  if errorlevel 1 (
    echo Composer install failed. Aborting.
    popd
    exit /b 1
  )
) else (
  echo Composer vendor directory exists, skipping install.
)

REM Setup .env file
if not exist ".env" (
  echo Copying .env.example to .env
  copy /Y ".env.example" ".env" >nul
) else (
  echo .env already exists.
)

REM Ensure sqlite database exists
if not exist "database" mkdir "database"
if not exist "database\database.sqlite" (
  echo Creating SQLite database file...
  type NUL > "database\database.sqlite"
) else (
  echo SQLite file exists.
)

REM Install backend JS dependencies (for Vite, etc.)
if exist "package.json" (
  if not exist "node_modules" (
    echo Installing backend npm dependencies...
    npm install
    if errorlevel 1 (
      echo Backend npm install failed. Aborting.
      popd
      exit /b 1
    )
  ) else (
    echo Backend node_modules exists, skipping npm install.
  )
)

REM Generate APP_KEY if it's missing or empty
set "APP_KEY_FOUND="
for /f "delims=" %%i in ('findstr /B /C:"APP_KEY=" ".env"') do (
  for /f "tokens=1,* delims==" %%A in ("%%i") do (
    if "%%B" NEQ "" set APP_KEY_FOUND=true
  )
)
if not defined APP_KEY_FOUND (
  echo Generating APP_KEY...
  php artisan key:generate --ansi
) else (
  echo APP_KEY is present.
)

REM Clear caches and run migrations
echo Caching configuration and routes...
php artisan config:cache
php artisan route:cache

echo Running migrations...
php artisan migrate --force --quiet

echo Ensuring storage link exists...
php artisan storage:link

REM Start Laravel backend in a new window
echo Starting Laravel backend (http://127.0.0.1:8000) in a new window...
start "Laravel Backend" cmd /k "cd /d "%BACKEND%" && php artisan serve --host=127.0.0.1 --port=8000"

popd
echo.

REM -----------------------------
REM Frontend Setup
REM -----------------------------
echo => Setting up frontend (%FRONTEND%)...
pushd "%FRONTEND%"

REM Install npm dependencies
if not exist "node_modules" (
  echo Installing frontend npm dependencies...
  npm install
  if errorlevel 1 (
    echo Frontend npm install failed. Aborting.
    popd
    exit /b 1
  )
) else (
  echo Frontend node_modules exists, skipping npm install.
)

REM Start Angular dev server in a new window
echo Starting Angular dev server (http://localhost:4200) in a new window...
start "Angular Frontend" cmd /k "cd /d "%FRONTEND%" && npm start"

popd
echo.

REM -----------------------------
REM Finish
REM -----------------------------
echo Backend and frontend servers have been started in new windows.
echo To stop them, simply close their respective command windows.
echo.
echo This launcher script will now close.
timeout /t 5 >nul

endlocal