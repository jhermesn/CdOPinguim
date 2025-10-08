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
sudo chmod +x setup.sh verify.sh
```

2) Executar o setup:
```bash
./setup.sh
CTF_CHALLENGE="UEPA-2025" CTF_SALT="SALT-SUPER" sudo ./setup.sh
```

3) Verificar (opcional):
```bash
./verify.sh -b /home/usuario/minicurso-linux-abcde
```