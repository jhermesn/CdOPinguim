#!/usr/bin/env bash
set -Eeuo pipefail

log() { printf "[+] %s\n" "$*"; }
err() { printf "[x] %s\n" "$*" >&2; }
die() { err "$*"; exit 1; }

require_cmd() { command -v "$1" >/dev/null 2>&1 || die "Comando requerido não encontrado: $1"; }

require_one_of_cmds() {
  local c1="$1"; local c2="$2"
  if ! command -v "$c1" >/dev/null 2>&1 && ! command -v "$c2" >/dev/null 2>&1; then
    die "É necessário ter um dos comandos instalados: $c1 ou $c2"
  fi
}

hmac_sha256_hex() {
  local key="$1"; shift
  local data="$*"
  if command -v openssl >/dev/null 2>&1; then
    printf "%s" "$data" | openssl dgst -sha256 -mac HMAC -macopt "key:$key" -r | awk '{print $1}'
  else
    python3 - "$key" "$data" <<'PY'
import sys, hmac, hashlib
key=sys.argv[1].encode()
data=sys.argv[2].encode()
print(hmac.new(key, data, hashlib.sha256).hexdigest())
PY
  fi
}

compute_fingerprint_string() {
  local machine_id="$(cat /etc/machine-id 2>/dev/null || echo no-machine-id)"
  local host="$(hostname 2>/dev/null || echo unknown-host)"
  local kern="$(uname -r 2>/dev/null || echo unknown-kernel)"
  local user_name="${USER:-$(id -un 2>/dev/null || echo user)}"
  local distro="unknown"
  if [ -r /etc/os-release ]; then
    . /etc/os-release
    distro="${ID:-linux}-${VERSION_ID:-0}"
  fi
  local wsl="${WSL_DISTRO_NAME:-no}"
  printf "host:%s|user:%s|mid:%s|kernel:%s|distro:%s|wsl:%s" "$host" "$user_name" "$machine_id" "$kern" "$distro" "$wsl"
}

derive_flag_from_fingerprint() {
  local salt="$1"; local challenge="$2"
  local fp
  fp="$(compute_fingerprint_string)"
  local data="challenge=${challenge}|fingerprint=${fp}"
  local mac
  mac="$(hmac_sha256_hex "$salt" "$data")"
  printf "FLAG{%s}\n" "${mac:0:24}"
}

usage() {
  cat <<EOF
Uso: $0 [-b <base_dir>] [-s <salt>] [-c <challenge>] [-f <secret_path>]
  -b: base_dir onde está o .fingerprint.json (default: deduzir do arquivo)
  -s: CTF_SALT (se omitido, tenta ler de .fingerprint.json ou $HOME/.ctf_pinguim.json)
  -c: CTF_CHALLENGE (idem acima)
  -f: caminho do secret.txt (se omitido, tenta encontrar com find)
EOF
}

main() {
  require_one_of_cmds openssl python3
  require_cmd grep
  require_cmd find

  local base_dir=""
  local salt="${CTF_SALT:-}"
  local challenge="${CTF_CHALLENGE:-}"
  local secret_path=""
  while getopts ":b:s:c:f:h" opt; do
    case "$opt" in
      b) base_dir="$OPTARG";;
      s) salt="$OPTARG";;
      c) challenge="$OPTARG";;
      f) secret_path="$OPTARG";;
      h) usage; exit 0;;
      :) die "Opção -$OPTARG requer um argumento";;
      *) usage; exit 1;;
    esac
  done

  # Tentar descobrir base_dir
  if [ -z "$base_dir" ]; then
    base_dir="$(find "$HOME" -maxdepth 2 -type f -name .fingerprint.json -printf '%h\n' 2>/dev/null | head -n1 || true)"
  fi
  [ -n "$base_dir" ] || die "base_dir não encontrado (sem .fingerprint.json)"

  # Carregar defaults de .fingerprint.json
  if [ -r "$base_dir/.fingerprint.json" ]; then
    salt="${salt:-$(grep -o '"salt":"[^"]*"' "$base_dir/.fingerprint.json" | cut -d'"' -f4)}"
    challenge="${challenge:-$(grep -o '"challenge":"[^"]*"' "$base_dir/.fingerprint.json" | cut -d'"' -f4)}"
  fi
  # Fallback ao arquivo no HOME
  if [ -z "$salt" ] && [ -r "$HOME/.ctf_pinguim.json" ]; then
    salt="$(grep -o '"salt":"[^"]*"' "$HOME/.ctf_pinguim.json" | cut -d'"' -f4)"
  fi
  if [ -z "$challenge" ] && [ -r "$HOME/.ctf_pinguim.json" ]; then
    challenge="$(grep -o '"challenge":"[^"]*"' "$HOME/.ctf_pinguim.json" | cut -d'"' -f4)"
  fi

  [ -n "$salt" ] || die "Salt não definido/encontrado"
  [ -n "$challenge" ] || die "Challenge não definido/encontrado"

  # Localizar secret.txt se não informado
  if [ -z "$secret_path" ]; then
    secret_path="$(find "$base_dir" -type f -name secret.txt -print 2>/dev/null | head -n1 || true)"
  fi
  [ -n "$secret_path" ] || die "secret.txt não encontrado em $base_dir"

  local expected
  expected="$(derive_flag_from_fingerprint "$salt" "$challenge")"
  local got
  got="$(grep -o 'FLAG{[0-9a-f]\{24\}}' "$secret_path" || true)"

  log "Esperado: $expected"
  if [ "$got" = "$expected" ]; then
    log "OK: secret.txt válido para esta máquina/desafio"
    exit 0
  fi
  err "Falha: secret.txt não corresponde (obtido: ${got:-<vazio>})"
  exit 2
}

main "$@"


