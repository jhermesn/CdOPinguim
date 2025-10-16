### Requisitos
- Ubuntu no WSL
- `openssl` ou `python3` (opcional, para verificação)

### Preparando o ambiente (WSL)
1) Instalar WSL e Ubuntu (se necessário):
```bash
wsl --install -d Ubuntu
```
2) Instalar dependências:
```bash
sudo apt update && sudo apt install -y git coreutils findutils grep tar openssl python3
```

### Uso rápido
1) Clonar o repositório e dar permissão de execução:
```bash
git clone https://github.com/jhermesn/CdOPinguim.git CdOPinguim && cd CdOPinguim
chmod +x setup.sh verify.sh
```

2) Executar o setup:
```bash
CTF_CHALLENGE="<NOME_DO_DESAFIO>" CTF_SALT="<UM_SALT_QUALQUER>" CTF_CLEANUP=1 ./setup.sh
```

3) Verificar (opcional):
```bash
./verify.sh -b <CAMINHO_BASE_DOS_ARQUIVOS>
```