#!/usr/bin/env bash
# Sync both release worktrees (cn / oversea) from main.
# - release/cn: fast-forward only (mirror of main, no channel commits)
# - release/oversea: merge main (keeps its channel config commit)
#
# Run from anywhere: bash scripts/sync-from-main.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> sync release/cn from main (ff-only)"
git -C "$ROOT/.worktrees/cn" merge main --ff-only

echo "==> sync release/oversea from main (merge, keeps oversea config)"
git -C "$ROOT/.worktrees/oversea" merge main --no-edit

echo
echo "synced."
echo "  main     = $(git -C "$ROOT" rev-parse --short HEAD)"
echo "  cn       = $(git -C "$ROOT/.worktrees/cn" rev-parse --short HEAD)"
echo "  oversea  = $(git -C "$ROOT/.worktrees/oversea" rev-parse --short HEAD)"
