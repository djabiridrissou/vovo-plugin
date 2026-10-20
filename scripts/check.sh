#!/usr/bin/env bash
# Validates every manifest with the backend engine (v1 contract).
# Defaults to the sibling backend (../backend or ../vovoscan-be); otherwise VOVOSCAN_BE=<path to the vovoscan-be repository>.
set -euo pipefail
cd "$(dirname "$0")/.."
backend="${VOVOSCAN_BE:-}"
for candidate in ../backend ../vovoscan-be; do
  [[ -z "$backend" && -f "$candidate/pyproject.toml" ]] && backend="$candidate"
done
if [[ -z "$backend" ]]; then
  echo "Backend not found: clone vovoscan-be next to this repository or set VOVOSCAN_BE." >&2
  exit 2
fi
# The schema here must be the engine's schema.
if ! cmp -s schema/source.schema.json "$backend/src/vovoscan/features/catalog/domain/contract/source.schema.json"; then
  echo "schema/source.schema.json differs from the backend contract: copy it again." >&2
  exit 1
fi
manifests=("$PWD"/sources/*/source.json)
(cd "$backend" && uv run --quiet vovoscan check-source "${manifests[@]}")
