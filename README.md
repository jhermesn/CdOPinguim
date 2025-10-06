### Requisitos
- Ubuntu no WSL
- `openssl` ou `python3`

### Uso rápido
1) Clonar e dar permissão de execução:
```bash
git clone https://github.com/jhermesn/CdOPinguim/ CdOPinguim && cd CdOPinguim
chmod +x setup.sh verify.sh
```

2) Executar o setup (opcionalmente fixando rodada e sal):
```bash
CTF_CHALLENGE="UEPA-2025-WSL" CTF_SALT="SALT-SUPER-SECRETO" ./setup.sh
# ou simplesmente
./setup.sh
```

3) Verificar o vencedor:
```bash
./verify.sh
# ou explicitando
./verify.sh -b /home/usuario/.base_dir -s SALT-SUPER-SECRETO -c UEPA-2025-WSL
```

### O que acontece
- `setup.sh`: cria um diretório base oculto no `$HOME`, gera uma FLAG única por máquina/rodada e esconde um `secret.txt` com pistas.
- `verify.sh`: recomputa a FLAG esperada e valida se o `secret.txt` encontrado corresponde à máquina/rodada.