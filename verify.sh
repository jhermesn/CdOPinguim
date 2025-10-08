#!/usr/bin/env bash
set -Eeuo pipefail

log(){ printf "[+] %s\n" "$*"; }
err(){ printf "[x] %s\n" "$*" >&2; }
die(){ err "$*"; exit 1; }

require_cmd(){ command -v "$1" >/dev/null 2>&1 || die "Comando requerido não encontrado: $1"; }
require_one_of_cmds(){ local c1="$1"; local c2="$2"; if ! command -v "$c1" >/dev/null 2>&1 && ! command -v "$c2" >/dev/null 2>&1; then die "É necessário ter um dos comandos instalados: $c1 ou $c2"; fi; }

hmac_sha256_hex(){ local key="$1"; shift; local data="$*"; if command -v openssl >/dev/null 2>&1; then printf "%s" "$data" | openssl dgst -sha256 -mac HMAC -macopt "key:$key" -r | awk '{print $1}'; else python3 - "$key" "$data" <<'PY'
import sys, hmac, hashlib
key=sys.argv[1].encode()
data=sys.argv[2].encode()
print(hmac.new(key, data, hashlib.sha256).hexdigest())
PY
fi; }

compute_fingerprint_string(){ local machine_id="$(cat /etc/machine-id 2>/dev/null || echo no-machine-id)"; local host="$(hostname 2>/dev/null || echo unknown-host)"; local kern="$(uname -r 2>/dev/null || echo unknown-kernel)"; local user_name="${USER:-$(id -un 2>/dev/null || echo user)}"; local distro="unknown"; if [ -r /etc/os-release ]; then . /etc/os-release; distro="${ID:-linux}-${VERSION_ID:-0}"; fi; local wsl="${WSL_DISTRO_NAME:-no}"; printf "host:%s|user:%s|mid:%s|kernel:%s|distro:%s|wsl:%s" "$host" "$user_name" "$machine_id" "$kern" "$distro" "$wsl"; }

derive_flag_from_fingerprint(){ local salt="$1"; local challenge="$2"; local fp; fp="$(compute_fingerprint_string)"; local data="challenge=${challenge}|fingerprint=${fp}"; local mac; mac="$(hmac_sha256_hex "$salt" "$data")"; printf "FLAG{%s}\n" "${mac:0:24}"; }

usage(){ cat <<EOF
Uso: $0 [-b <base_dir>]
  -b: diretório base do ambiente (default: detectar o mais recente 'minicurso-linux-*' em $HOME)
EOF
}

detect_base_dir(){
  find "$HOME" -maxdepth 1 -type d -name 'minicurso-linux-*' -printf '%T@ %p\n' 2>/dev/null | sort -nr | awk 'NR==1{print $2}'
}

main(){
  require_one_of_cmds openssl python3
  require_cmd grep
  require_cmd find

  local base_dir=""
  while getopts ":b:h" opt; do
    case "$opt" in
      b) base_dir="$OPTARG";;
      h) usage; exit 0;;
      :) die "Opção -$OPTARG requer um argumento";;
      *) usage; exit 1;;
    esac
  done

  if [ -z "$base_dir" ]; then base_dir="$(detect_base_dir || true)"; fi
  [ -n "$base_dir" ] || die "Não foi possível detectar o diretório base. Informe com -b."
  [ -d "$base_dir" ] || die "Diretório base inválido: $base_dir"

  log "Verificando FLAG no ambiente: $base_dir"

  local salt=""
  local challenge=""
  if [ -r "$base_dir/.fingerprint.json" ]; then
    salt="$(grep -o '"salt":"[^"]*"' "$base_dir/.fingerprint.json" | cut -d'"' -f4)"
    challenge="$(grep -o '"challenge":"[^"]*"' "$base_dir/.fingerprint.json" | cut -d'"' -f4)"
  fi
  if [ -z "$salt" ] && [ -r "$HOME/.ctf_pinguim.json" ]; then salt="$(grep -o '"salt":"[^"]*"' "$HOME/.ctf_pinguim.json" | cut -d'"' -f4)"; fi
  if [ -z "$challenge" ] && [ -r "$HOME/.ctf_pinguim.json" ]; then challenge="$(grep -o '"challenge":"[^"]*"' "$HOME/.ctf_pinguim.json" | cut -d'"' -f4)"; fi

  [ -n "$salt" ] || die "Salt não encontrado (rode novamente o setup)"
  [ -n "$challenge" ] || die "Challenge não encontrado (rode novamente o setup)"

  local expected
  expected="$(derive_flag_from_fingerprint "$salt" "$challenge")"

  local secret_path
  secret_path="$(find "$base_dir" -type f -name secret.txt -print 2>/dev/null | head -n1 || true)"
  [ -n "$secret_path" ] || die "Arquivo secreto não encontrado no ambiente"

  local got
  got="$(grep -o 'FLAG{[0-9a-f]\{24\}}' "$secret_path" || true)"

  log "Esperado: $expected"
  if [ "$got" = "$expected" ]; then log "OK: FLAG válida"; printf "%s\n" "$secret_path"; exit 0; fi
  err "Falha: FLAG inválida (obtido: ${got:-<vazio>})"; exit 2
}

main "$@"


