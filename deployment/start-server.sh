#!/bin/sh
set -eu
action=start
version=
preview=false
directory=${XDG_CONFIG_HOME:-"$HOME/.config"}/luau-decompiler/server
port=7879
port_explicit=false
domain=
https=false
docker=docker
if [ "$#" -gt 0 ] && [ "${1#-}" = "$1" ]; then action=$1; shift; fi
while [ "$#" -gt 0 ]; do
    case "$1" in
        --version) version=$2; shift 2 ;;
        --preview) preview=true; shift ;;
        --directory) directory=$2; shift 2 ;;
        --port) port=$2; port_explicit=true; shift 2 ;;
        --domain) domain=$2; shift 2 ;;
        --https) https=true; shift ;;
        --docker) docker=$2; shift 2 ;;
        *) printf '%s\n' 'Unsupported bootstrap option' >&2; exit 1 ;;
    esac
done
case "$action" in start|stop|status|update|rollback) ;; *) printf '%s\n' 'Action must be start, stop, status, update, or rollback' >&2; exit 1 ;; esac
for tool in "$docker" curl sha256sum od tr sed grep awk cut wc flock timeout; do command -v "$tool" >/dev/null 2>&1 || { printf '%s\n' "Required command is unavailable: $tool" >&2; exit 1; }; done
case "$port" in ''|*[!0-9]*) printf '%s\n' 'Port must be numeric' >&2; exit 1 ;; esac
[ "$port" -ge 1024 ] && [ "$port" -le 65535 ] || { printf '%s\n' 'Port must be 1024..65535' >&2; exit 1; }
script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repository=$(sed -n 's/^[[:space:]]*"container_image":[[:space:]]*"\([^"]*\)".*/\1/p' "$script_directory/../release.json")
printf '%s\n' "$repository" | grep -Eq '^ghcr\.io/[a-z0-9_.-]+/[a-z0-9_.-]+$' || { printf '%s\n' 'No configured container destination in release.json' >&2; exit 1; }
umask 077
[ ! -L "$directory" ] || { printf '%s\n' 'Server directory must not be a symbolic link' >&2; exit 1; }
if [ -d "$directory" ] && [ ! -f "$directory/ownership.json" ] && [ -n "$(ls -A "$directory")" ]; then printf '%s\n' 'Nonempty destination is not a managed server directory' >&2; exit 1; fi
mkdir -p -- "$directory"
directory=$(CDPATH= cd -- "$directory" && pwd -P)
exec 9>"$directory/.server.lock"
flock -n 9 || { printf '%s\n' 'Another bootstrap operation holds the server lock' >&2; exit 1; }
owner=$directory/ownership.json
credential_file=$directory/credential.txt
current=$directory/server.env
previous=$directory/previous.env
pending=$directory/pending.env
compose_file=$directory/compose.yaml
get_json() { sed -n 's/^[[:space:]]*"'"$2"'"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$1"; }
get_env() { sed -n 's/^'"$2"'=//p' "$1"; }
write_owner() {
    printf '{\n  "schema": 1,\n  "product": "luau-decompiler-server",\n  "project": "%s",\n  "compose_sha256": "%s",\n  "caddy_sha256": "%s"\n}\n' "$project" "$compose_hash" "$caddy_hash" >"$owner.new"
    mv -f -- "$owner.new" "$owner"
}
if [ -f "$owner" ]; then
    grep -Eq '"schema":[[:space:]]*1([,[:space:]]|$)' "$owner" && [ "$(get_json "$owner" product)" = luau-decompiler-server ] || { printf '%s\n' 'Invalid server ownership metadata' >&2; exit 1; }
    project=$(get_json "$owner" project)
    printf '%s\n' "$project" | grep -Eq '^luau-decompiler-[0-9a-f]{12}$' || { printf '%s\n' 'Invalid server project identity' >&2; exit 1; }
    compose_hash=$(get_json "$owner" compose_sha256)
    caddy_hash=$(get_json "$owner" caddy_sha256)
else
    project=luau-decompiler-$(printf '%s' "$directory" | sha256sum | cut -c1-12)
    compose_hash=
    caddy_hash=
    write_owner
fi
if [ ! -f "$credential_file" ]; then od -An -N32 -tx1 /dev/urandom | tr -d ' \n' >"$credential_file"; fi
credential=$(cat "$credential_file")
printf '%s\n' "$credential" | grep -Eq '^[0-9a-f]{64}$' || { printf '%s\n' 'Credential file must contain the existing generated 64-character token' >&2; exit 1; }
unset LUAU_DECOMPILER_IMAGE LUAU_DECOMPILER_TOKEN LUAU_DECOMPILER_PORT LUAU_DECOMPILER_VERSION COMPOSE_PROFILES DECOMPILER_DOMAIN
docker_run() { docker_limit=$1; shift; timeout --kill-after=5 "$docker_limit" "$docker" "$@"; }
docker_run 60 version --format '{{.Server.Version}}' >/dev/null
docker_run 60 compose version --short | grep -Eq '^v?2\.' || { printf '%s\n' 'Docker Compose v2 is required' >&2; exit 1; }
for name in compose.yaml Caddyfile; do
    target=$directory/$name
    expected=$compose_hash
    [ "$name" = compose.yaml ] || expected=$caddy_hash
    if [ -f "$target" ]; then
        [ "$(sha256sum "$target" | cut -d' ' -f1)" = "$expected" ] || { printf '%s\n' "Managed deployment file was modified; reconcile it explicitly: $name" >&2; exit 1; }
    else cp -- "$script_directory/$name" "$target"; fi
done
compose_hash=$(sha256sum "$compose_file" | cut -d' ' -f1)
caddy_hash=$(sha256sum "$directory/Caddyfile" | cut -d' ' -f1)
write_owner
compose() { environment=$1; shift; docker_run 60 compose --project-name "$project" --env-file "$environment" --file "$compose_file" "$@"; }
endpoint() { printf 'http://127.0.0.1:%s' "$(get_env "$1" LUAU_DECOMPILER_PORT)"; }
check_server() {
    environment=$1
    wait_mode=$2
    url=$(endpoint "$environment")
    expected_version=$(get_env "$environment" LUAU_DECOMPILER_VERSION)
    deadline=$(($(date +%s)+60))
    while [ "$(date +%s)" -lt "$deadline" ]; do
        if printf 'Authorization: Bearer %s\n' "$credential" | curl --silent --fail --max-time 3 --max-filesize 1048576 --header @- "$url/readyz" >"$directory/ready.json"; then
            if grep -Eq '"ready":[[:space:]]*true' "$directory/ready.json"; then break; fi
        fi
        [ "$wait_mode" = true ] || { printf '%s\n' 'Server is not ready' >&2; return 1; }
        sleep 1
    done
    grep -Eq '"ready":[[:space:]]*true' "$directory/ready.json" || { printf '%s\n' 'Container startup deadline elapsed' >&2; return 1; }
    observed_version=$(sed -n 's/.*"package_version":[[:space:]]*"\([^"]*\)".*/\1/p' "$directory/ready.json")
    [ "$observed_version" = "$expected_version" ] || { printf '%s\n' 'Container version differs from resolved image version' >&2; return 1; }
    remaining=$((deadline-$(date +%s)))
    [ "$remaining" -gt 0 ] || return 1
    [ "$remaining" -le 30 ] || remaining=30
    printf 'Authorization: Bearer %s\n' "$credential" | curl --silent --show-error --fail --max-time "$remaining" --max-filesize 1048576 --header @- --header 'Content-Type: application/json' --data-binary '{"source":"local value: number = 42\nreturn value\n","input_format":"luau_source","reconstruction_config":{"output_policy":"verified_typed"}}' "$url/v1/process" >"$directory/diagnostic.json" || return 1
    for pattern in '"complete":[[:space:]]*true' '"required_passed":[[:space:]]*true' '"output_policy":[[:space:]]*"verified_typed"' '"meaningful_typing":[[:space:]]*\{[[:space:]]*"passed":[[:space:]]*true' '"syntax":[[:space:]]*"passed"' '"compilation":[[:space:]]*"passed"' '"strict_analysis":[[:space:]]*"passed"'; do
        grep -Eq "$pattern" "$directory/diagnostic.json" || { printf '%s\n' 'Small verified-typed operation failed; inspect protected diagnostic.json' >&2; return 1; }
    done
    printf '%s\n' "$url"
}
case "$action" in stop|status|rollback) [ -f "$current" ] || { printf '%s\n' 'No active managed server configuration exists' >&2; exit 1; } ;; esac
if [ "$action" = stop ]; then
    printf 'Authorization: Bearer %s\n' "$credential" | curl --silent --fail --max-time 3 --header @- --request POST --data '' "$(endpoint "$current")/v1/shutdown" >/dev/null || :
    compose "$current" stop --timeout 40
    printf '%s\n' 'Server stopped; configuration and credentials were preserved.'
    exit 0
fi
if [ "$action" = status ]; then check_server "$current" false; exit; fi
if [ -f "$current" ]; then [ "$(get_env "$current" LUAU_DECOMPILER_TOKEN)" = "$credential" ] || { printf '%s\n' 'Credential and active configuration differ; reconcile the explicit change' >&2; exit 1; }; fi
if [ "$action" = rollback ]; then
    [ -f "$previous" ] || { printf '%s\n' 'No previous successful server configuration exists' >&2; exit 1; }
    cp -- "$previous" "$pending"
else
    version_explicit=true
    if [ -z "$version" ] && [ -f "$current" ]; then version=$(get_env "$current" LUAU_DECOMPILER_VERSION); version_explicit=false; fi
    printf '%s\n' "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$' || { printf '%s\n' 'Provide an explicit published semantic version using --version' >&2; exit 1; }
    case "$version" in *-*) [ "$version_explicit" = false ] || [ "$preview" = true ] || { printf '%s\n' 'Release candidates require --preview' >&2; exit 1; } ;; esac
    if [ -n "$domain" ]; then printf '%s\n' "$domain" | grep -Eq '^[A-Za-z0-9][A-Za-z0-9.-]*[A-Za-z0-9]$' || { printf '%s\n' 'Domain must be a DNS hostname' >&2; exit 1; }; fi
    [ "$https" = false ] || [ -n "$domain" ] || { printf '%s\n' 'HTTPS requires --domain, DNS, and ports 80/443' >&2; exit 1; }
    image=$repository:$version
    docker_run 300 pull --quiet "$image" >/dev/null
    all_digests=$(docker_run 60 image inspect --format '{{range .RepoDigests}}{{println .}}{{end}}' "$image")
    digest=$(printf '%s\n' "$all_digests" | while IFS= read -r entry; do case "$entry" in "$repository"@sha256:*) printf '%s\n' "$entry" ;; esac; done)
    [ "$(printf '%s\n' "$digest" | wc -l)" -eq 1 ] && printf '%s\n' "${digest#*@sha256:}" | grep -Eq '^[0-9a-f]{64}$' || { printf '%s\n' 'Image did not resolve to one configured immutable repository digest' >&2; exit 1; }
    if [ -f "$current" ]; then cp -- "$current" "$pending"; else : >"$pending"; fi
    put() { awk -v key="$1" -v value="$2" 'BEGIN{found=0} index($0,key"=")==1{print key"="value;found=1;next} {print} END{if(!found)print key"="value}' "$pending" >"$pending.new"; mv -f -- "$pending.new" "$pending"; }
    put LUAU_DECOMPILER_IMAGE "$digest"
    put LUAU_DECOMPILER_VERSION "$version"
    put LUAU_DECOMPILER_TOKEN "$credential"
    if [ -f "$current" ] && [ "$port_explicit" = false ]; then port=$(get_env "$current" LUAU_DECOMPILER_PORT); fi
    put LUAU_DECOMPILER_PORT "$port"
    [ -z "$domain" ] || put DECOMPILER_DOMAIN "$domain"
    [ "$https" = false ] || put COMPOSE_PROFILES https
fi
if compose "$pending" up --detach --quiet-pull >/dev/null && url=$(check_server "$pending" true); then
    [ ! -f "$current" ] || cp -- "$current" "$previous.new"
    [ ! -f "$previous.new" ] || mv -f -- "$previous.new" "$previous"
    mv -f -- "$pending" "$current"
    printf '%s\n' "Server ready: $url" "Credential file: $credential_file; retrieve it explicitly when needed. Routine commands do not print it."
else
    if [ -f "$current" ]; then compose "$current" up --detach --quiet-pull >/dev/null; check_server "$current" true >/dev/null; else compose "$pending" down >/dev/null; fi
    printf '%s\n' 'Server activation failed; previous working configuration retained.' >&2
    exit 1
fi
