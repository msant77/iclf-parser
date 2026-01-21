#!/usr/bin/env bash
# Update the globally installed iclf CLI after code changes
#
# Why this is needed:
# When you `dart pub global activate --source path .`, Dart creates a compiled
# snapshot in .dart_tool/pub/bin/iclf_parser/*.snapshot for faster startup.
# This snapshot does NOT auto-update when you modify source code.
# Deleting it forces recompilation on next run.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "Clearing CLI snapshot cache..."
rm -f "$PROJECT_DIR/.dart_tool/pub/bin/iclf_parser/"*.snapshot 2>/dev/null || true

echo "Activating iclf globally from local source..."
dart pub global activate --source path . --overwrite

echo "Done. Run 'iclf' to use the updated CLI."
