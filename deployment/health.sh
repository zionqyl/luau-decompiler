#!/bin/sh
set -eu
printf 'Authorization: Bearer %s\n' "$LUAU_DECOMPILER_TOKEN" | curl --silent --show-error --fail --max-time 3 --header @- "${LUAU_DECOMPILER_READINESS_URL:-http://127.0.0.1:7879/readyz}" >/dev/null
