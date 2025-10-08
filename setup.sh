#!/usr/bin/env bash
set -Eeuo pipefail

log(){ printf "[+] %s\n" "$*"; }
err(){ printf "[x] %s\n" "$*" >&2; }
die(){ err "$*"; exit 1; }

require_cmd(){ command -v "$1" >/dev/null 2>&1 || die "Comando requerido não encontrado: $1"; }
require_one_of_cmds(){ local c1="$1"; local c2="$2"; if ! command -v "$c1" >/dev/null 2>&1 && ! command -v "$c2" >/dev/null 2>&1; then die "É necessário ter um dos comandos instalados: $c1 ou $c2"; fi; }

random_letters(){ local len="${1:-8}"; tr -dc 'a-z' </dev/urandom | head -c "$len"; }
random_hex(){ local bytes="${1:-8}"; if command -v openssl >/dev/null 2>&1; then openssl rand -hex "$bytes"; else hexdump -vn "$bytes" -e '16/1 "%02x"' /dev/urandom; fi; }

script_dir(){ local src="${BASH_SOURCE[0]}"; while [ -h "$src" ]; do local dir; dir="$(cd -P "$(dirname "$src")" >/dev/null 2>&1 && pwd)"; src="$(readlink "$src")"; [[ "$src" != /* ]] && src="$dir/$src"; done; cd -P "$(dirname "$src")" >/dev/null 2>&1 && pwd; }

hmac_sha256_hex(){ local key="$1"; shift; local data="$*"; if command -v openssl >/dev/null 2>&1; then printf "%s" "$data" | openssl dgst -sha256 -mac HMAC -macopt "key:$key" -r | awk '{print $1}'; else python3 - "$key" "$data" <<'PY'
import sys, hmac, hashlib
key=sys.argv[1].encode()
data=sys.argv[2].encode()
print(hmac.new(key, data, hashlib.sha256).hexdigest())
PY
fi; }

compute_fingerprint_string(){ local machine_id="$(cat /etc/machine-id 2>/dev/null || echo no-machine-id)"; local host="$(hostname 2>/dev/null || echo unknown-host)"; local kern="$(uname -r 2>/dev/null || echo unknown-kernel)"; local user_name="${USER:-$(id -un 2>/dev/null || echo user)}"; local distro="unknown"; if [ -r /etc/os-release ]; then . /etc/os-release; distro="${ID:-linux}-${VERSION_ID:-0}"; fi; local wsl="${WSL_DISTRO_NAME:-no}"; printf "host:%s|user:%s|mid:%s|kernel:%s|distro:%s|wsl:%s" "$host" "$user_name" "$machine_id" "$kern" "$distro" "$wsl"; }

derive_flag_from_fingerprint(){ local salt="$1"; local challenge="$2"; local fp; fp="$(compute_fingerprint_string)"; local data="challenge=${challenge}|fingerprint=${fp}"; local mac; mac="$(hmac_sha256_hex "$salt" "$data")" || die "Falha ao gerar HMAC"; printf "FLAG{%s}\n" "${mac:0:24}"; }

embed_flag_in_template(){ local template="$1"; local out="$2"; local flag="$3"; if [ -r "$template" ]; then awk -v repl="$flag" '{gsub(/\{\{SECRET\}\}/, repl); print $0}' "$template" >"$out"; else printf "%s\n" "$flag" >"$out"; fi; }

make_decoys_in_dir(){ local target="$1"; local count="${2:-8}"; mkdir -p "$target"; local -a exts=("txt" "log" "conf" "md" "dat" "" "bak"); for _ in $(seq 1 "$count"); do local name="$(random_letters 6)"; local ext="${exts[$((RANDOM % ${#exts[@]}))]}"; local file="$target/$name"; [[ -n "$ext" ]] && file="$file.$ext"; { for i in $(seq 1 $((3 + RANDOM % 9))); do printf "linha %02d: %s\n" "$i" "$(random_hex 8)"; done; } >"$file"; done; }

create_tar_with_file(){ local tar_path="$1"; local inner="$2"; local content="$3"; local tmpd=""; tmpd="$(mktemp -d)"; printf "%s\n" "$content" >"$tmpd/$inner"; tar -C "$tmpd" -czf "$tar_path" "$inner"; rm -rf "$tmpd"; }

is_wsl(){ grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; }

main(){
  require_cmd bash
  require_cmd find
  require_cmd grep
  require_cmd tar
  require_one_of_cmds openssl python3

  local base_dir="${HOME}/minicurso-linux-$(random_letters 5)"
  mkdir -p "$base_dir"

  local challenge="${CTF_CHALLENGE:-UEPA-$(date -u +%Y%m%d)}"
  local salt
  if [[ -n "${CTF_SALT:-}" ]]; then salt="$CTF_SALT"; else salt="$(random_hex 16)"; log "CTF_SALT não informado; gerado automaticamente. Salve para verificação: $salt"; fi
  local flag
  flag="$(derive_flag_from_fingerprint "$salt" "$challenge")"

  cat >"${base_dir}/README.txt" <<'EOF'
Objetivo: encontrar o pinguim.
Sugestão de comandos: ls, cd, mkdir, cat, rm, cp, mv, find, grep, chmod, tar.
Pistas:
- Há um diretório oculto (prefixo ".") com um arquivo .tar.gz contendo uma dica.
- Existe um arquivo com a palavra PINGUIM em algum lugar.
Boa prática!
EOF

  local -a dirs=()
  for i in $(seq 1 5); do
    local d1="$(random_letters 6)"
    local d2="$(random_letters 6)"
    mkdir -p "${base_dir}/${d1}/${d2}"
    dirs+=("${base_dir}/${d1}")
    dirs+=("${base_dir}/${d1}/${d2}")
  done

  local hidden_dir="${base_dir}/.$(random_letters 7)"
  mkdir -p "$hidden_dir"
  mkdir -p "${hidden_dir}/hint"
  printf "%s\n" "Use 'find' para localizar um arquivo a partir do diretório base." > "${hidden_dir}/hint/dica.txt"
  tar -C "${hidden_dir}/hint" -czf "${hidden_dir}/DICA_2.tar.gz" "dica.txt"
  rm -rf "${hidden_dir}/hint"

  for d in "${dirs[@]}"; do
    for n in 1 2 3; do
      printf "anotacao %d - %s\n" "$n" "$(date -u +%s)" > "${d}/$(random_letters 5).txt"
    done
  done

  local idx_ping="$((RANDOM % ${#dirs[@]}))"
  printf "%s\n" "Hoje é um bom dia para PINGUIM aprender Linux." > "${dirs[$idx_ping]}/diario.md"

  local final_dir="${base_dir}/$(random_letters 6)/$(random_letters 6)/.$(random_letters 6)"
  mkdir -p "$final_dir"
  local tpl_path
  tpl_path="$(script_dir)/secret.txt"
  embed_flag_in_template "$tpl_path" "${final_dir}/secret.txt" "$flag"
  chmod 400 "${final_dir}/secret.txt"

  local fp_json="${base_dir}/.fingerprint.json"
  {
    printf '{"base_dir":"%s",' "$base_dir"
    printf '"flag":"%s",' "$flag"
    printf '"salt":"%s",' "$salt"
    printf '"challenge":"%s",' "$challenge"
    printf '"fingerprint":"%s",' "$(compute_fingerprint_string | sed 's/\\/\\\\/g;s/\"/\\\"/g')"
    printf '"algo":"HMAC-SHA256-hex-24"}'
  } > "$fp_json"

  {
    printf '{"salt":"%s",' "$salt"
    printf '"challenge":"%s"}' "$challenge"
  } > "$HOME/.ctf_pinguim.json"

  printf "%s\n" "Dica rápida: tente 'grep -R PINGUIM .'" > "${base_dir}/LEIA-ME-2.txt"

  log "Ambiente criado em: $base_dir"
  log "Agora pratique com ls, cd, cat, find, grep, chmod e tar."

  local repo_root=""
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
  local script_root
  script_root="$(script_dir)"

  # Fallbacks: se não conseguir detectar via git, tenta a pasta do script
  if [[ -z "$repo_root" && -d "$script_root/.git" ]]; then
    repo_root="$script_root"
  fi
  # Último recurso: se a pasta do script se chama CdOPinguim, assume como raiz do repo
  if [[ -z "$repo_root" && "$(basename "$script_root")" == "CdOPinguim" ]]; then
    repo_root="$script_root"
  fi

  if [[ -n "$repo_root" && -d "$repo_root" && "$repo_root" != "/" && "$repo_root" != "$HOME" ]]; then
    log "Removendo repositório clonado: $repo_root"
    cd "$HOME"
    rm -rf --one-file-system -- "$repo_root"
    log "Repositório removido. Ambiente preservado em: $base_dir"
  else
    log "Nenhuma raiz de repositório detectada para remoção; ignorando limpeza."
  fi
}

main "$@"