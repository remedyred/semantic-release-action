#!/bin/bash

set -e

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

  local COMMAND=""

  if has_script "$script_name"; then
    echo "Running $script_name"

    COMMAND="pnpm run $script_name"
    if [ "$silent" = true ]; then
      COMMAND="$COMMAND --silent"
    fi

    if [ "$noBail" = true ]; then
      COMMAND="$COMMAND --no-bail"
    fi

    eval "$COMMAND"
  else
    echo "No script found for $script_name"
  fi
}

echo "Install dependencies"
pnpm install --frozen-lockfile

runScript "build"

runScript "test"

runScript "docs" true true

runScript "fix"

echo "Releasing"
pnpm semantic-release
