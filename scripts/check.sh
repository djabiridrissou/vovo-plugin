#!/usr/bin/env bash
# Valide tous les manifestes avec le moteur du backend (contrat v1).
# Par défaut, le backend voisin (../backend ou ../vovoscan-be) ; sinon VOVOSCAN_BE=<chemin du dépôt vovoscan-be>.
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
# Le schéma d'ici doit être celui du moteur.
if ! cmp -s schema/source.schema.json "$backend/src/vovoscan/features/catalog/domain/contract/source.schema.json"; then
  echo "schema/source.schema.json differs from the backend contract: copy it again." >&2
  exit 1
fi
manifests=("$PWD"/sources/*/source.json)
(cd "$backend" && uv run --quiet vovoscan check-source "${manifests[@]}")
