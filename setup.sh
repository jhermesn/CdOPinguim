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
  require_cmd grep
  require_cmd find
  require_cmd tar
  require_cmd base64
  require_one_of_cmds openssl python3

  if ! is_wsl; then log "Aviso: não parece ser WSL; seguindo assim mesmo."; fi

  local base_name=".$(random_letters 6)-$(random_hex 4)"
  local base_dir="${HOME}/${base_name}"
  mkdir -p "$base_dir"

  local challenge="${CTF_CHALLENGE:-UEPA-$(date -u +%Y%m%d)}"
  local salt
  if [[ -n "${CTF_SALT:-}" ]]; then salt="$CTF_SALT"; else salt="$(random_hex 16)"; log "CTF_SALT não informado; gerado automaticamente. Salve para verificação: $salt"; fi

  local flag
  flag="$(derive_flag_from_fingerprint "$salt" "$challenge")"

  cat >"${base_dir}/README.txt" <<'EOF'
Objetivo: encontrar o arquivo "secret.txt".
Regras:
- Você pode usar qualquer comando do Linux.
- Explore diretórios, permissões, arquivos ocultos, links, buscas, compressão e conteúdo.
Dicas gerais:
- Procure recursivamente com find/grep.
- Verifique arquivos ocultos (prefixo .).
- Extraia arquivos .tar.gz.
- Decodifique conteúdo em base64.
- Entenda permissões: r (ler), w (escrever), x (executar/listar).
Boa caçada!
EOF

  local -a dirs=()
  for i in $(seq 1 8); do
    local d1="$(random_letters 7)"
    local d2="$(random_letters 7)"
    local d3="$(random_letters 7)"
    mkdir -p "${base_dir}/${d1}/${d2}/${d3}"
    dirs+=("${base_dir}/${d1}")
    dirs+=("${base_dir}/${d1}/${d2}")
    dirs+=("${base_dir}/${d1}/${d2}/${d3}")
  done

  local hidden_dir="${base_dir}/.$(random_letters 8)"
  mkdir -p "$hidden_dir"
  local tar_name="$(random_letters 6).tar.gz"
  create_tar_with_file "${hidden_dir}/${tar_name}" "pista1.txt" "Pista 1: Existe um arquivo de texto em algum lugar contendo a palavra PINGUIM.
Dica: use grep recursivo para encontrá-lo (ex.: grep -R \"PINGUIM\" .)."

  for d in "${dirs[@]}"; do make_decoys_in_dir "$d" $((6 + RANDOM % 10)); done
  make_decoys_in_dir "$hidden_dir" 5

  local idx_ping="$((RANDOM % ${#dirs[@]}))"
  local dir_with_ping="${dirs[$idx_ping]}"
  mkdir -p "$dir_with_ping"

  local idx_link="$((RANDOM % ${#dirs[@]}))"
  local dir_with_symlink="${dirs[$idx_link]}"
  mkdir -p "$dir_with_symlink"

  local secret_container="${base_dir}/$(random_letters 6)/$(random_letters 6)"
  mkdir -p "$secret_container"

  local inner_tar="${secret_container}/$(random_letters 5).tar.gz"
  local clue3_plain="Pista 3: Use 'find' para localizar um arquivo chamado exatamente 'secret.txt' a partir do diretório base desta atividade. Exemplo:
find . -type f -name secret.txt 2>/dev/null
Se não estiver no diretório base, navegue até onde começou a dinâmica."
  local tmpc=""
  tmpc="$(mktemp -d)"
  printf "%s" "$clue3_plain" | base64 > "${tmpc}/clue3.b64"
  tar -C "$tmpc" -czf "$inner_tar" "clue3.b64"
  rm -rf "$tmpc"

  chmod 111 "$secret_container"

  cat >"${dir_with_ping}/anotacao.txt" <<EOF
Hoje é um bom dia para pinguins curiosos.
PINGUIM
Pista 2: Existe um link simbólico chamado "atalho" em algum lugar. Siga-o.
Dica: use find para localizar links simbólicos: find . -type l -ls
EOF

  cat >"${dir_with_ping}/runme.sh" <<'EOF'
#!/usr/bin/env bash
echo "Dica extra: verifique permissões de diretórios (ls -ld) e entenda a diferença entre r e x em diretórios."
EOF
  chmod +x "${dir_with_ping}/runme.sh"

  ln -s "$secret_container" "${dir_with_symlink}/atalho"

  local deep_a=".$(random_letters 7)"
  local deep_b="$(random_letters 5) com espacos"
  local deep_c=".$(random_letters 6)"
  local final_dir="${base_dir}/${deep_a}/${deep_b}/${deep_c}/$(random_letters 6)"
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

  local fake_txt="${base_dir}/$(random_letters 6)/$(random_letters 6).txt"
  mkdir -p "$(dirname "$fake_txt")"
  printf "nao-e-texto-de-verdade" | gzip -c > "$fake_txt"

  log "Ambiente criado em: $base_dir"
  log "Desafio: $challenge"
  log "Ferramenta de verificação: ${base_dir}/.fingerprint.json (e opcionalmente $HOME/.ctf_pinguim.json)"
  log "Agora feche este terminal ou comece a dinâmica a partir do seu $HOME."
  log "Boa sorte aos participantes!"

  local repo_root=""
  if repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"; then
    if [[ -n "$repo_root" && -d "$repo_root/.git" && "$repo_root" != "/" && "$repo_root" != "$HOME" ]]; then
      log "Removendo repositório clonado: $repo_root"
      cd "$HOME"
      rm -rf --one-file-system -- "$repo_root"
      log "Repositório removido."
    fi
  fi
}

main "$@"