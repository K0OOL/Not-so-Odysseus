#!/usr/bin/env bash
# bootstrap-clean-env.sh
# ──────────────────────────────────────────────────────────────────────────────
# Creates /app/clean_env inside the running Odysseus container.
# This satisfies the Odysseus UI venv validator — set the venv path field to
# `/app/clean_env` in the web panel to turn the indicator Green/Healthy.
#
# Usage (from repo root, inside Git Bash):
#   bash scripts/bootstrap-clean-env.sh
#
# Optionally override the container name:
#   ODYSSEUS_CONTAINER=my-odysseus-1 bash scripts/bootstrap-clean-env.sh
#
# This script is idempotent — safe to re-run after container recreates.
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

CONTAINER="${ODYSSEUS_CONTAINER:-odysseus-odysseus-1}"

echo "→ Bootstrapping clean_env inside container: ${CONTAINER}"

docker exec -it "$CONTAINER" bash -c "
  set -euo pipefail

  echo '  [1/3] Creating venv with system site-packages...'
  python3 -m venv /app/clean_env --system-site-packages

  echo '  [2/3] Replacing venv python symlink with system python3...'
  rm -f /app/clean_env/bin/python
  ln -s /usr/local/bin/python3 /app/clean_env/bin/python

  echo '  [3/3] Verifying symlink...'
  /app/clean_env/bin/python --version

  echo ''
  echo '✓ clean_env ready.'
  echo '  In the Odysseus web panel, set the venv path to: /app/clean_env'
"

echo "Done."
