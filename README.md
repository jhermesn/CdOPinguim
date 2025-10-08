### Requisitos
- Ubuntu no WSL
- `openssl` ou `python3` (para verificação opcional)

### Preparando o ambiente (WSL)
1) Instalar WSL e Ubuntu (se necessário):
```bash
wsl --install -d Ubuntu
```
2) Atualizar pacotes e instalar dependências:
```bash
sudo apt update && sudo apt install -y bash coreutils findutils grep tar openssl python3
```

### Uso rápido
1) Clonar e dar permissão de execução:
```bash
git clone https://github.com/jhermesn/CdOPinguim/ CdOPinguim && cd CdOPinguim
chmod +x setup.sh verify.sh
```

2) Executar o setup:
```bash
./setup.sh
# opcional: fixar rodada/sal para validação posterior (ex.: para sorteio)
CTF_CHALLENGE="UEPA-2025" CTF_SALT="SALT-SUPER" sudo ./setup.sh
```

3) Verificar (opcional):
```bash
./verify.sh
# ou apontando para um diretório base específico
./verify.sh -b /home/usuario/minicurso-linux-abcde
```

### O que acontece
- `setup.sh`: cria um diretório de prática no `$HOME`, espalha pistas leves (inclui um `.tar.gz` oculto e um arquivo com "PINGUIM") e esconde um arquivo final onde embute uma FLAG única no template `secret.txt` substituindo `{{SECRET}}`. A FLAG é `FLAG{<HMAC-24-hex>}` derivada de `HMAC-SHA256(salt, "challenge=...|fingerprint=...")` e salva também metadados em `.fingerprint.json`.
- `verify.sh`: re-lê `salt` e `challenge`, recomputa a FLAG esperada e valida se a FLAG embutida em `secret.txt` corresponde.

### Importante (auto-limpeza do repositório)
- Ao final do `./setup.sh`, o repositório clonado será removido automaticamente, deixando somente o ambiente do desafio dentro do seu `$HOME` (pasta `minicurso-linux-xxxxx`).
- Isso evita que os participantes voltem ao código e mantém o foco no uso de comandos Linux.

### Como validar o vencedor (organização)
1) Peça ao participante para rodar `./verify.sh` (ou `./verify.sh -b <caminho>`), no mesmo ambiente/WSL onde executou o setup.
2) Se você fixou `CTF_CHALLENGE` e `CTF_SALT` ao criar o ambiente, a validação é reproduzível para sorteio/premiação.
3) O verificador retornará "OK: FLAG válida" quando a FLAG do arquivo secreto corresponder à esperada.

### Dicas de uso em aula (sem spoilers)
- Incentive uso de `ls -la`, `find`, `grep -R`, `tar -xzf` e checagem de permissões.
- As pistas são intencionais, porém genéricas; não mencionam o nome do arquivo final.