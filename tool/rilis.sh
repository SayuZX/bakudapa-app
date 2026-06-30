#!/usr/bin/env bash
set -euo pipefail
tanggal="$(date +%Y%m%d)"
target="${1:-appbundle}"
shift || true
debug_info="build/debug-info/${tanggal}"
flutter build "$target" \
  --release \
  --obfuscate \
  --split-debug-info="$debug_info" \
  --dart-define=TANGGAL_BUILD="$tanggal" \
  "$@""
