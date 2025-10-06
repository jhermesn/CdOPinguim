### Requisitos
- Ubuntu no WSL
- `openssl` ou `python3`

### Arquivos
- `setup.sh`: prepara o ambiente e gera um `secret.txt` único por máquina/rodada.
- `verify.sh`: recomputa e valida o FLAG encontrado pelo participante.
- `secret.txt`: template; `{{SECRET}}` será substituído durante o setup.

### Uso
1) Clone e dê permissão de execução (em WSL):
```bash
git clone https://github.com/jhermesn/CdOPinguim/ CdOPinguim && cd CdOPinguim
chmod +x setup.sh verify.sh
```

2) Execute o setup (opcionalmente fixando rodada e sal):
```bash
# valores opcionais para padronizar a rodada
CTF_CHALLENGE="UEPA-2025-WSL" CTF_SALT="SALT-SUPER-SECRETO" ./setup.sh
# ou simplesmente
./setup.sh
```

3) Verifique o vencedor:
```bash
./verify.sh
# ou explicitando
./verify.sh -b /home/usuario/.base_dir -s SALT-SUPER-SECRETO -c UEPA-2025-WSL
```