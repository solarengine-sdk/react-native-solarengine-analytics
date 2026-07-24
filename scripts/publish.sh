#!/usr/bin/env bash
# Publish a channel release from its worktree.
# usage: bash scripts/publish.sh <cn|oversea> <version> [--dry-run]
#
# Steps: reset local name tweak → sync main → bump version → (oversea: strip -cn) → bob build → npm publish
# package.json changes are NOT committed (publish-time only), per release convention.
set -euo pipefail

CHANNEL="${1:?usage: publish.sh <cn|oversea> <version> [--dry-run]}"
VERSION="${2:?usage: publish.sh <cn|oversea> <version> [--dry-run]}"
DRY_RUN="${3:-}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WT="$ROOT/.worktrees/$CHANNEL"

[ "$CHANNEL" = "cn" ] || [ "$CHANNEL" = "oversea" ] || { echo "ERROR: channel must be cn|oversea"; exit 1; }

echo "==> channel=$CHANNEL version=$VERSION dry_run=${DRY_RUN:-no}"

cd "$WT"

# 1. reset any local package.json name tweak (from previous publish) before sync
git checkout -- package.json 2>/dev/null || true

# 2. sync from main
bash "$ROOT/scripts/sync-from-main.sh"

cd "$WT"

# 3. bump version (no git tag, no commit — publish-time only)
npm version "$VERSION" --no-git-tag-version --no-commit-hooks

# 4. oversea: strip -cn suffix from package name
if [ "$CHANNEL" = "oversea" ]; then
  node -e "const f='./package.json';const p=JSON.parse(require('fs').readFileSync(f));p.name='solarengine-analysis-react-native';require('fs').writeFileSync(f,JSON.stringify(p,null,2)+'\n')"
  # re-resolve workspace + lockfile with the new name (was -cn)
  yarn install
fi

echo "==> package: $(node -p "require('./package.json').name") @ $(node -p "require('./package.json').version")"

# 5. build lib/ (bob build)
yarn prepare

# 6. publish
if [ "$DRY_RUN" = "--dry-run" ]; then
  echo "==> npm publish --dry-run"
  npm publish --dry-run
else
  echo "==> npm publish (REAL)"
  npm publish
fi

echo "==> done: $CHANNEL $VERSION"
