# Hardcode In APKS

**Hardcode In APKS** é uma ferramenta automatizada para detectar valores hardcoded, como secrets, chaves de API e outras informações sensíveis em arquivos APK (Android Package).

![]()

## Instalação

Siga os passos abaixo para instalar e configurar a ferramenta:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install apktool git
git clone https://github.com/Pauloxc6/hardcode_apks.git
cd hardcode_apks
sudo ./main.sh
```

## Funcionalidades
  Detecção de secrets hardcoded<br>
  Identificação de chaves de API e outras informações sensíveis<br>
  Relatórios detalhados sobre possíveis vulnerabilidades<br>