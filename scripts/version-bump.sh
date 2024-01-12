#!/bin/bash
set -e

function echo_usage() {
  echo "Usage: $0 (--no-bump) [npm version args] - Bump the specified version of the top-level package.json file, then copy that version to all child packages. If '--no-bump' is specified, the version will not be bumped, but the existing version will be copied to all child packages."
  echo "       $0 -h|--help - Show this help message"
  echo
  echo "NOTE: This script accepts all valid \`npm version\` arguments, such as 'major', 'minor', 'patch', etc. See \`npm version --help\` for more information."
  echo
  echo "Options:"
  echo "  --no-bump:        Do not bump the version, just set all packages to the current version"
  echo "  --package-dir:    A directory containing sub-packages to update. Defaults to 'libs', 'apps' and 'packages'. May be passed more than once."
  echo "  --repo-root-file: A file that indicates the root of the repository. Defaults to 'pnpm-workspace.yaml'."
  echo
}

function exit_with_error() {
  >&2 echo_usage
  >&2 echo
  >&2 echo "E: $1"
  exit 1
}

if ! command -v jq &> /dev/null; then
  exit_with_error "jq not found. You must install jq to use this script"
fi

ARGS=()
NO_BUMP=
DIRS=()
REPO_ROOT_FILE="${REPO_ROOT_FILE:-pnpm-workspace.yaml}"
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) echo_usage; exit 0 ;;
    --no-bump) NO_BUMP=1 ;;
    --package-dir) DIRS+=("$2"); shift ;;
    --repo-root-file) REPO_ROOT_FILE="$2"; shift ;;
    *) ARGS+=("$1") ;;
  esac
  shift
done

ROOT="$(readlink -f "$PWD")"
while ! [ -e "$ROOT/$REPO_ROOT_FILE" ] && [ "$ROOT" != "/" ]; do ROOT="$(readlink -f "$ROOT/..")"; done
if ! [ -e "$ROOT/$REPO_ROOT_FILE" ]; then
  exit_with_error "Could not find '$REPO_ROOT_FILE' in '$PWD' or any parent directory."
fi

cd "$ROOT"

if [ "${#DIRS[@]}" -eq 0 ]; then
  DIRS=(apps libs packages)
fi
FOUND_A_DIR=0
for d in "${DIRS[@]}"; do
  if [ -d "$d" ]; then
    FOUND_A_DIR=1
    break
  fi
done
if [ "$FOUND_A_DIR" -eq 0 ]; then
  exit_with_error "Could not find any of the following directories: ${DIRS[*]}"
fi

if [ "${#ARGS[@]}" -eq 0 ] && [ -z "$NO_BUMP" ]; then
  exit_with_error "Please specify 'major', 'minor' or 'patch'"
fi

if [ -z "$NO_BUMP" ]; then
  pnpm version --commit-hooks false --git-tag-version false "${ARGS[@]}" >/dev/null
fi
VERSION="$(jq -r '.version' package.json)"

COUNT=0
for d in "${DIRS[@]}"; do
  if ! [ -d "$d" ]; then continue; fi
  for pkg in "$d"/*/package.json; do
    if ! [ -e "$pkg" ]; then continue; fi
    OUTPUT="$(jq --arg version "$VERSION" '.version|=$version' "$pkg")"
    echo "$OUTPUT" > "$pkg"
    COUNT="$((COUNT+1))"
  done
done

echo "All versions set to $VERSION ($COUNT affected package(s))"
