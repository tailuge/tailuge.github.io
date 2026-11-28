#!/usr/bin/env bash
# Lint this site's HTML/CSS using the toolchain already installed in ../billiards,
# so nothing has to be installed in this repo.
#
#   ./lint.sh                 # lints index.html
#   ./lint.sh index.html      # explicit files (paths are relative to this repo)
#
# Override the toolchain location with BILLIARDS_DIR=/path/to/billiards.
# Exits 0 only when both linters pass.

set -uo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
toolchain="${BILLIARDS_DIR:-$root/../billiards}"

stylelint="$toolchain/node_modules/.bin/stylelint"
htmlvalidate="$toolchain/node_modules/.bin/html-validate"
stylelintrc="$toolchain/.stylelintrc.json"
htmlvalidatec="$toolchain/test/.htmlvalidate.json"

missing=0
for path in "$stylelint" "$htmlvalidate" "$stylelintrc" "$htmlvalidatec"; do
  if [ ! -e "$path" ]; then
    echo "lint.sh: missing $path" >&2
    missing=1
  fi
done
if [ "$missing" -ne 0 ]; then
  echo "lint.sh: run 'yarn install' in $toolchain, or set BILLIARDS_DIR" >&2
  exit 2
fi

cd "$root" || exit 2

if [ "$#" -eq 0 ]; then
  set -- index.html
fi

status=0

echo "stylelint"
"$stylelint" --config "$stylelintrc" "$@" || status=1

echo
echo "html-validate"
"$htmlvalidate" -c "$htmlvalidatec" "$@" || status=1

if [ "$status" -eq 0 ]; then
  echo
  echo "lint.sh: clean"
fi

exit "$status"
