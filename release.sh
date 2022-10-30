#!/bin/bash

set -e

DRY_RUN=${DRY_RUN:-false}
RELEASE_SCRIPT=${RELEASE_SCRIPT:-}
AVAILABLE_SCRIPTS=$(npm run)

has_script() {
  local script_name="$1"
  local SCRIPT_COUNT
  SCRIPT_COUNT=$(echo "$AVAILABLE_SCRIPTS" | grep -c "^  $script_name")
  [[ $SCRIPT_COUNT -gt 0 ]]
}

runScript() {
  local script_name="$1"
  local silent="$2"
  local noBail="$3"

  local PARAMS=""

  if has_script "$script_name"; then
    echo "Running $script_name"

    if [ "$silent" = true ]; then
      PARAMS="$PARAMS --silent"
    fi

    if [ "$noBail" = true ]; then
      PARAMS="$PARAMS --no-bail"
    fi

    if [ "$DRY_RUN" = true ]; then
      echo "[DRY RUN] pnpm run $PARAMS $script_name"
    else
      pnpm run "$PARAMS $script_name"
    fi
  else
    echo "No script found for $script_name"
  fi
}

function release() {
  if [[ -n "$RELEASE_SCRIPT" ]]; then
    runScript "$RELEASE_SCRIPT"
  else
    if [ "$DRY_RUN" = true ]; then
      pnpm semantic-release --dry-run
    else
      pnpm semantic-release
    fi
  fi
}

echo "Install dependencies"
pnpm install --frozen-lockfile

runScript "build"

runScript "test"

runScript "docs" true true

runScript "fix"

release
