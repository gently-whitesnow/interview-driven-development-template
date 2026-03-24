#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." >/dev/null 2>&1 && pwd)"
FRONTEND_DIR="$ROOT_DIR/src/frontend"

if [[ ! -f "$FRONTEND_DIR/package.json" ]]; then
  echo "Cannot find frontend package.json at $FRONTEND_DIR"
  exit 1
fi

cd "$FRONTEND_DIR"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1"
    exit 1
  }
}

require_npm_script() {
  node -e "const p=require('./package.json'); process.exit(p.scripts && p.scripts['$1'] ? 0 : 1)"
}

run_step() {
  local name="$1"
  shift
  echo
  echo "==> $name"
  "$@"
}

require_cmd node
require_cmd npm

if [[ ! -d "./node_modules" ]]; then
  echo "node_modules not found — running npm install"
  npm install
fi

for script in format build lint deps:check test; do
  if ! require_npm_script "$script"; then
    echo "Missing npm script: $script"
    exit 1
  fi
done

run_step "format"  npm run format
run_step "build"   npm run build
run_step "deps:check" npm run deps:check
run_step "lint (autofix)" npm run lint -- --fix
run_step "lint (strict)"  npm run lint -- --max-warnings 0
run_step "test"    npm test

echo
echo "Frontend verification passed."
