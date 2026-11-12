#!/bin/sh
set -eu
project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
entrypoint="${1:-$project_root/deployment/entrypoint.sh}"
work=$(mktemp -d "$project_root/artifacts/entrypoint-contract.XXXXXX")
mkdir "$work/bin"
cat >"$work/bin/curl" <<'CURL'
#!/bin/sh
cat >/dev/null
printf 'request\n' >>"$CURL_CALLS"
if [ "$CURL_FAIL" = 1 ]; then
    exit 22
fi
: >"$SERVER_STOP"
CURL
cat >"$work/server.sh" <<'SERVER'
#!/bin/sh
trap 'exit "$SERVER_STATUS"' TERM INT
printf '%s\n' "$$" >"$SERVER_READY"
if [ "$SERVER_IMMEDIATE" = 1 ]; then
    exit "$SERVER_STATUS"
fi
while [ ! -f "$SERVER_STOP" ]; do
    sleep 0.01
done
exit "$SERVER_STATUS"
SERVER
chmod +x "$work/bin/curl"
export PATH="$work/bin:$PATH"
export LUAU_DECOMPILER_TOKEN=entrypoint_contract_token_32_bytes
export CURL_CALLS="$work/calls"
launcher=""
cleanup() {
    if [ -n "$launcher" ]; then
        kill -TERM "$launcher" 2>/dev/null || :
        wait "$launcher" 2>/dev/null || :
    fi
}
trap cleanup EXIT
run_case() {
    identity=$1
    expected=$2
    export CURL_FAIL=$3 SERVER_STATUS=$4 SERVER_IMMEDIATE=$5
    export SERVER_STOP="$work/$identity.stop" SERVER_READY="$work/$identity.ready"
    sh "$entrypoint" sh "$work/server.sh" &
    launcher=$!
    attempt=0
    while [ ! -f "$SERVER_READY" ]; do
        attempt=$((attempt+1))
        if [ "$attempt" -ge 300 ]; then
            printf 'FAIL %s readiness deadline\n' "$identity" >&2
            exit 1
        fi
        sleep 0.01
    done
    if [ "$SERVER_IMMEDIATE" = 0 ]; then
        kill -TERM "$launcher"
    fi
    actual=0
    wait "$launcher" || actual=$?
    launcher=""
    if [ "$actual" -ne "$expected" ]; then
        printf 'FAIL %s expected=%s actual=%s\n' "$identity" "$expected" "$actual" >&2
        exit 1
    fi
    printf 'PASS %s status=%s\n' "$identity" "$actual"
}
run_case graceful_zero 0 0 0 0
run_case graceful_nonzero 17 0 17 0
run_case failed_request_child_status 23 1 23 0
run_case normal_zero 0 0 0 1
run_case normal_nonzero 29 0 29 1
test "$(wc -l <"$CURL_CALLS")" -eq 3
printf 'entrypoint controlled shell contracts passed: 5\n'
