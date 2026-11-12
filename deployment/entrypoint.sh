#!/bin/sh
set -eu
"$@" &
server_pid=$!
shutdown() {
    trap '' TERM INT
    if ! printf 'Authorization: Bearer %s\n' "${LUAU_DECOMPILER_TOKEN:-}" | curl --silent --show-error --fail --max-time 5 --header @- --request POST --data '' "${LUAU_DECOMPILER_SHUTDOWN_URL:-http://127.0.0.1:7879/v1/shutdown}" >/dev/null; then
        kill -TERM "$server_pid" 2>/dev/null || :
    fi
    status=0
    wait "$server_pid" || status=$?
    exit "$status"
}
trap shutdown TERM INT
status=0
wait "$server_pid" || status=$?
exit "$status"
