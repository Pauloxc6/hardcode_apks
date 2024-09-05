function logs_out() {
    # Diretório onde os logs serão salvos
    local log_dir="./logs"
    
    # Cria o diretório de logs se não existir
    [ ! -d "$log_dir" ] && mkdir -p "$log_dir"

    # Arquivo de log com data e hora
    local log_file="$log_dir/log_$(date +%Y-%m-%d_%H-%M-%S).log"

    # Define o tamanho máximo para o arquivo de log (5 MB)
    local max_size=5242880

    # Função para rotacionar o arquivo de log quando o limite for atingido
    rotate_log() {
        if [ -f "$log_file" ] && [ $(stat -c%s "$log_file") -ge $max_size ]; then
            mv "$log_file" "$log_file.$(date +%Y-%m-%d_%H-%M-%S)"
        fi
    }

    # Função para limpar logs antigos (mantém apenas os 10 mais recentes)
    clean_old_logs() {
        find "$log_dir" -type f -name "*.log" | sort -r | tail -n +11 | xargs rm -f
    }

    # Função para comprimir logs maiores que 5 MB
    compress_logs() {
        find "$log_dir" -type f -name "*.log" -size +5M | while read file; do
            gzip "$file"
        done
    }

    # Adiciona um cabeçalho com metadados
    echo "===========================" | tee -a "$log_file"
    echo "Log Start: $(date)" | tee -a "$log_file"
    echo "===========================" | tee -a "$log_file"

    # Rotaciona logs se necessário
    rotate_log
    
    # Executa a limpeza de logs antigos
    clean_old_logs

    # Compressão de logs antigos
    compress_logs

    # Redireciona a saída para o arquivo de log e exibe no terminal
    tee -a "$log_file"
    
    # Adiciona um rodapé ao final da execução
    echo "===========================" | tee -a "$log_file"
    echo "Log End: $(date)" | tee -a "$log_file"
    echo "===========================" | tee -a "$log_file"
}

function view_logs() {
    echo

    # Obtém a lista de arquivos de log no diretório
    dir_log=$(find "$PWD/logs" -mindepth 1 -maxdepth 1 -type f)

    # Verifica se há logs disponíveis
    if [ -z "$dir_log" ]; then
        echo -e "\033[31;1m[-] Nenhum log encontrado. [-]\033[0m"
        exit 1
    fi

    # Exibe os logs disponíveis
    i=0
    for item in $dir_log; do
        echo -e "\033[37;1m[+] File [\033[33;1m$i\033[37;1m]: \033[33;1m$item \033[37;1m[+]\033[0m"
        ((i++))
    done

    echo
    echo -e "\033[37;1m[+] Selecione o log: \033[0m"

    # Leitura da seleção do usuário
    read -p "select> " vlog

    # Verifica se o índice selecionado é válido
    if [[ $vlog =~ ^[0-9]+$ ]] && [ "$vlog" -ge 0 ] && [ "$vlog" -lt "$i" ]; then
        # Seleciona o log correspondente
        selected_log=$(echo "$dir_log" | sed -n "$((vlog + 1))p")
        echo -e "\033[37;1m[+] Você selecionou: $selected_log [+]\033[0m"
        
        # Exibe o conteúdo do log selecionado
        cat "$selected_log"
    else
        echo -e "\033[31;1m[-] Seleção inválida. [-]\033[0m"
        exit 1
    fi

    # Verifica e remove logs com mais de 30 dias
    if find "$PWD/logs" -mtime +30 | grep -q .; then
        echo -e "\033[31;1m[+] Existem logs com mais de 30 dias. [+]\033[0m"
        read -p "[+] Deseja remover os logs antigos (y/n)? " yn

        if [[ "$yn" == "y" || "$yn" == "Y" || "$yn" == "yes" || "$yn" == "YES" ]]; then
            echo -e "\033[31;1m[+] Deletando logs antigos [+]\033[0m"
            find "$PWD/logs" -mtime +30 -delete
        else
            echo -e "\033[31;1m[-] Operação cancelada. [-]\033[0m"
        fi
    fi
}

function verify_apks() {
    # Encontra os diretórios dentro de 'apks_extract'
    out=$(find $PWD/apks_extract -mindepth 1 -maxdepth 1 -type d)

    # Lista os diretórios encontrados
    i=0
    for item in $out; do
        echo -e "\033[37;1m[+] File [\033[33;1m$i\033[37;1m]: \033[33;1m$item \033[37;1m[+]\033[0m"
        ((i++))
    done

    echo
    echo -e "\033[37;1m[+] Selecione o apk: \033[0m"

    read -p "root> " vapk

    if [[ $vapk =~ ^[0-9]+$ ]] && [ "$vapk" -ge 0 ] && [ "$vapk" -lt "$i" ]; then
        selected_apk=$(echo "$out" | sed -n "$((vapk + 1))p")
        if [ -d "$selected_apk" ]; then
            echo -e "\033[37;1m[+] Você selecionou: $selected_apk [+]\033[0m"
        else
            echo -e "\033[31;1m[-] O diretório selecionado não é válido. [-]\033[0m"
            exit 1
        fi
    else
        echo -e "\033[31;1m[-] Seleção inválida. [-]\033[0m"
        exit 1
    fi
}


function remove_apks() {
    # Encontra os diretórios dentro de 'apks_extract'
    out=$(find $PWD/apks_extract -mindepth 1 -maxdepth 1 -type d)

    # Lista os diretórios encontrados
    i=0
    for item in $out; do
        echo -e "\033[37;1m[+] File [\033[33;1m$i\033[37;1m]: \033[33;1m$item \033[37;1m[+]\033[0m"
        ((i++))
    done

    echo
    echo -e "\033[37;1m[+] Selecione o apk: \033[0m"
    read -p "root> " vapk

    if [[ $vapk =~ ^[0-9]+$ ]] && [ "$vapk" -ge 0 ] && [ "$vapk" -lt "$i" ]; then
        selected_apk=$(echo "$out" | sed -n "$((vapk + 1))p")
        if [ -d "$selected_apk" ]; then
            echo -e "\033[37;1m[+] Você selecionou: $selected_apk [+]\033[0m"
            
            echo -e "\033[37;1m[+] Deseja remover o apk [$selected_apk] (y/n): \033[0m"
            read -p "root> " ops

            if [[ "$ops" == "y" || "$ops" == "Y" ]]; then
                rm -rf "$selected_apk"
                echo -e "\033[32;1m[+] APK removido com sucesso. [+]\033[0m"
            else
                echo -e "\033[31;1m[-] Operação cancelada. [-]\033[0m"
            fi
        else
            echo -e "\033[31;1m[-] O diretório selecionado não é válido. [-]\033[0m"
            exit 1
        fi
    else
        echo -e "\033[31;1m[-] Seleção inválida. [-]\033[0m"
        exit 1
    fi
}


function api_check() {
    echo
    verify_apks

    # Verifica se o APK foi selecionado corretamente
    if [ -z "$selected_apk" ]; then
        echo -e "\033[31;1m[-] Nenhum APK selecionado. [-]\033[0m"
        exit 1
    fi

    #-------------------------------------------
    echo -e "\e[37;1mAPI Check\e[0m"

    # Busca por chaves de API (Payload 1)
    echo -e "\e[37;1m[*] Payload 1 (Keys) [*]\e[0m"
    grep -HirEon "(apikey|APIKEY) (:|=| : | = ) ( |\"|')[0-9a-zA-Z\-]{20,100}" --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 1 (Keys) [DONE]\e[0m"

    # Busca por chaves relacionadas a autenticação (Payload 2)
    echo -e "\e[37;1m[*] Payload 2 (Keys) [*]\e[0m"
    grep -HirEn "(api[-_]?key|secret|token|auth[-_]?key|apikey|access[-_]?key)" --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 2 (Keys) [DONE]\e[0m"

    # Busca por URLs com chaves como parâmetros (Payload 3)
    echo -e "\e[37;1m[*] Payload 3 (Url+Key) [*]\e[0m"
    grep -HirEn "https?:\/\/[^\s]*[?&]key=[A-Za-z0-9]+" --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 3 (Url+Key) [DONE]\e[0m"

    # Busca por chaves dentro de strings longas (Payload 4)
    echo -e "\e[37;1m[*] Payload 4 (Keys) [*]\e[0m"
    grep -HirEn "['\"]([A-Za-z0-9]{20,})['\"]" --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 4 (Keys) [DONE]\e[0m"

    # Busca por URLs de API com subdomínio "api." (Payload 5)
    echo -e "\e[37;1m[*] Payload 5 (Path+Key) [*]\e[0m"
    grep -HirEn "https?://api\.[a-zA-Z0-9./?=_-]*" --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 5 (Path+Key) [DONE]\e[0m"

    # Busca por URLs com endpoints comuns de APIs (Payload 6)
    echo -e "\e[37;1m[*] Payload 6 (Endpoints) [*]\e[0m"
    grep -HirEn "https?://[a-zA-Z0-9./?=_-]*(/v[0-9]+|/api/|/oauth/|/auth/|/token/|aws)" --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 6 (Endpoints) [DONE]\e[0m"

    # Busca por URLs genéricas (Payload 7)
    echo -e "\e[37;1m[*] Payload 7 (Generic Url) [*]\e[0m"
    grep -HirEn "https?://[a-zA-Z0-9./?=_-]+" --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 7 (Generic Url) [DONE]\e[0m"

    # Busca por URLs de API dentro de strings nos arquivos smali (Payload 8)
    echo -e "\e[37;1m[*] Payload 8 (Path) [*]\e[0m"
    grep -HirEn 'const-string [vp][0-9]+, "https?://[a-zA-Z0-9./?=_-]*api[a-zA-Z0-9./?=_-]*"' --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 8 (Path) [DONE]\e[0m"

    # Busca por URLs de API com subdomínio "api." dentro de strings (Payload 9)
    echo -e "\e[37;1m[*] Payload 9 (Path+Key) [*]\e[0m"
    grep -HirEn 'const-string [vp][0-9]+, "https?://api\.[a-zA-Z0-9./?=_-]*"' --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 9 (Path+Key) [DONE]\e[0m"

    # Busca por URLs com endpoints comuns dentro de strings (Payload 10)
    echo -e "\e[37;1m[*] Payload 10 (Endpoints) [*]\e[0m"
    grep -HirEn 'const-string [vp][0-9]+, "https?://[a-zA-Z0-9./?=_-]*(/v[0-9]+|/api/|/oauth/|/auth/|/token/|/aws)"' --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 10 (Endpoints) [DONE]\e[0m"

    # Busca por URLs genéricas dentro de strings (Payload 11)
    echo -e "\e[37;1m[*] Payload 11 (Generic Url) [*]\e[0m"
    grep -HirEn 'const-string [vp][0-9]+, "https?://[a-zA-Z0-9./?=_-]+"' --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 11 (Generic Url) [DONE]\e[0m"

    # Busca por chaves em formato hexadecimal (Payload 12)
    echo -e "\e[37;1m[*] Payload 12 (Hexadecimal Keys) [*]\e[0m"
    grep -HirEn 'const-string [vp][0-9]+, "([A-Fa-f0-9]{32,})"' --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 12 (Hexadecimal Keys) [DONE]\e[0m"

    # Busca por chaves em formato Base64 (Payload 13)
    echo -e "\e[37;1m[*] Payload 13 (Base64 Keys) [*]\e[0m"
    grep -HirEn 'const-string [vp][0-9]+, "([A-Za-z0-9+/=]{20,})"' --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 13 (Base64 Keys) [DONE]\e[0m"

    # Busca por referências a variáveis de ambiente (Payload 14)
    echo -e "\e[37;1m[*] Payload 14 (Environment Variables) [*]\e[0m"
    grep -HirEn 'invoke-static .* Ljava/lang/System;->getenv\(Ljava/lang/String;\)Ljava/lang/String;' --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 14 (Environment Variables) [DONE]\e[0m"

    #------------------------------------------------------------------
    # Advanced
    #------------------------------------------------------------------

     # Busca por chaves de API (Payload 1)
    echo -e "\e[37;1m[*] Payload 1 (Keys) [*]\e[0m"
    rg -Hn --color "apikey|APIKEY" $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 1 (Keys) [DONE]\e[0m"

    # Busca por chaves relacionadas a autenticação (Payload 2)
    echo -e "\e[37;1m[*] Payload 2 (Keys) [*]\e[0m"
    rg -Hn --color "api[-_]?key|secret|token|auth[-_]?key|apikey|access[-_]?key" $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 2 (Keys) [DONE]\e[0m"

    # Busca por URLs com chaves como parâmetros (Payload 3)
    echo -e "\e[37;1m[*] Payload 3 (Url+Key) [*]\e[0m"
    rg -Hn --color "https?:\/\/[^\s]*[?&]key=[A-Za-z0-9]+" $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 3 (Url+Key) [DONE]\e[0m"

    # Busca por chaves dentro de strings longas (Payload 4)
    echo -e "\e[37;1m[*] Payload 4 (Keys) [*]\e[0m"
    rg -Hn --color "'[A-Za-z0-9]{20,}'" $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 4 (Keys) [DONE]\e[0m"

    # Busca por URLs de API com subdomínio "api." (Payload 5)
    echo -e "\e[37;1m[*] Payload 5 (Path+Key) [*]\e[0m"
    rg -Hn --color "https?://api\.[a-zA-Z0-9./?=_-]*" $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 5 (Path+Key) [DONE]\e[0m"

    # Busca por URLs com endpoints comuns de APIs (Payload 6)
    echo -e "\e[37;1m[*] Payload 6 (Endpoints) [*]\e[0m"
    rg -Hn --color "https?://[a-zA-Z0-9./?=_-]*(/v[0-9]+|/api/|/oauth/|/auth/|/token/|aws)" $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 6 (Endpoints) [DONE]\e[0m"

    # Busca por URLs genéricas (Payload 7)
    echo -e "\e[37;1m[*] Payload 7 (Generic Url) [*]\e[0m"
    rg -Hn --color "https?://[a-zA-Z0-9./?=_-]+" $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 7 (Generic Url) [DONE]\e[0m"

    # Busca por URLs de API dentro de strings nos arquivos smali (Payload 8)
    echo -e "\e[37;1m[*] Payload 8 (Path) [*]\e[0m"
    rg -Hn --color 'const-string [vp][0-9]+, "https?://[a-zA-Z0-9./?=_-]*api[a-zA-Z0-9./?=_-]*"' $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 8 (Path) [DONE]\e[0m"

    # Busca por URLs de API com subdomínio "api." dentro de strings (Payload 9)
    echo -e "\e[37;1m[*] Payload 9 (Path+Key) [*]\e[0m"
    rg -Hn --color 'const-string [vp][0-9]+, "https?://api\.[a-zA-Z0-9./?=_-]*"' $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 9 (Path+Key) [DONE]\e[0m"

    # Busca por URLs com endpoints comuns dentro de strings (Payload 10)
    echo -e "\e[37;1m[*] Payload 10 (Endpoints) [*]\e[0m"
    rg -Hn --color 'const-string [vp][0-9]+, "https?://[a-zA-Z0-9./?=_-]*(/v[0-9]+|/api/|/oauth/|/auth/|/token/|/aws)"' $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 10 (Endpoints) [DONE]\e[0m"

    # Busca por URLs genéricas dentro de strings (Payload 11)
    echo -e "\e[37;1m[*] Payload 11 (Generic Url) [*]\e[0m"
    rg -Hn --color 'const-string [vp][0-9]+, "https?://[a-zA-Z0-9./?=_-]+"' $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 11 (Generic Url) [DONE]\e[0m"

    # Busca por chaves em formato hexadecimal (Payload 12)
    echo -e "\e[37;1m[*] Payload 12 (Hexadecimal Keys) [*]\e[0m"
    rg -Hn --color 'const-string [vp][0-9]+, "([A-Fa-f0-9]{32,})"' $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 12 (Hexadecimal Keys) [DONE]\e[0m"

    # Busca por chaves em formato Base64 (Payload 13)
    echo -e "\e[37;1m[*] Payload 13 (Base64 Keys) [*]\e[0m"
    rg -Hn --color 'const-string [vp][0-9]+, "([A-Za-z0-9+/=]{20,})"' $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 13 (Base64 Keys) [DONE]\e[0m"

    # Busca por referências a variáveis de ambiente (Payload 14)
    echo -e "\e[37;1m[*] Payload 14 (Environment Variables) [*]\e[0m"
    rg -Hn --color 'invoke-static .* Ljava/lang/System;->getenv\(Ljava/lang/String;\)Ljava/lang/String;' $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 14 (Environment Variables) [DONE]\e[0m"


}

function secret_check() {
    echo
    verify_apks

    # Verifica se o APK foi selecionado corretamente
    if [ -z "$selected_apk" ]; then
        echo -e "\033[31;1m[-] Nenhum APK selecionado. [-]\033[0m"
        exit 1
    fi

    #-------------------------------------------
    echo -e "\e[37;1mSecret Check\e[0m"

    # Busca por parâmetros sensíveis (Payload 1)
    echo -e "\e[37;1m[*] Payload 1 (Param) [*]\e[0m"
    grep -HirEon "(secret|SECRET|Secret|passphrase|key|KEY|Key|cipher|CIPHER|Cipher|salt|SALT|Salt)" --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 1 (Param) [DONE]\e[0m"

    # Busca por strings longas que podem conter segredos (Payload 2)
    echo -e "\e[37;1m[*] Payload 2 (Strings Long) [*]\e[0m"
    grep -HirEn "['\"]([A-Za-z0-9+/=]{32,})['\"]" --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 2 (Strings Long) [DONE]\e[0m"

    # Busca por strings em formato hexadecimal (Payload 3)
    echo -e "\e[37;1m[*] Payload 3 (Strings Hexa) [*]\e[0m"
    grep -HirEn "['\"]([A-Fa-f0-9]{32,})['\"]" --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 3 (Strings Hexa) [DONE]\e[0m"

    # Busca por segredos em arquivos de configuração (Payload 4)
    echo -e "\e[37;1m[*] Payload 4 (Files) [*]\e[0m"
    grep -HirEn "(secret|key|cipher|salt)" --include=\*.{env,json,yaml,yml,ini,conf} --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 4 (Files) [DONE]\e[0m"

    # Busca por chaves RSA privadas (Payload 5)
    echo -e "\e[37;1m[*] Payload 5 (RSA) [*]\e[0m"
    grep -r "-----BEGIN.*PRIVATE KEY-----" --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 5 (RSA) [DONE]\e[0m"

    # Busca por constantes que podem conter segredos (Payload 6)
    echo -e "\e[37;1m[*] Payload 6 (Const Strings) [*]\e[0m"
    grep -HirEn 'const-string [vp][0-9]+, "([A-Za-z0-9+/=]{32,})"' --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 6 (Const Strings) [DONE]\e[0m"

    # Busca por constantes em formato hexadecimal (Payload 7)
    echo -e "\e[37;1m[*] Payload 7 (Strings Hexa) [*]\e[0m"
    grep -HirEn 'const-string [vp][0-9]+, "([A-Fa-f0-9]{32,})"' --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 7 (Strings Hexa) [DONE]\e[0m"

    # Busca por métodos e variáveis que possam indicar uso de criptografia (Payload 8)
    echo -e "\e[37;1m[*] Payload 8 (Vars) [*]\e[0m"
    grep -HirEn "(getString|decode|decrypt|secret|key|cipher|salt|AES|DES)" --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 8 (Vars) [DONE]\e[0m"

    # Busca por referências a variáveis de ambiente (Payload 9)
    echo -e "\e[37;1m[*] Payload 9 (Referências) [*]\e[0m"
    grep -HirEn 'invoke-static .* Ljava/lang/System;->getenv\(Ljava/lang/String;\)Ljava/lang/String;' --color $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 9 (Referências) [DONE]\e[0m"

    #----------------------------------------------------------------
    # Advanced
    #----------------------------------------------------------------
    # Busca por parâmetros sensíveis (Payload 1)
    echo -e "\e[37;1m[*] Payload 1 (Param) [*]\e[0m"
    rg -Hn --color "secret|SECRET|Secret|passphrase|key|KEY|Key|cipher|CIPHER|Cipher|salt|SALT|Salt" $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 1 (Param) [DONE]\e[0m"

    # Busca por strings longas que podem conter segredos (Payload 2)
    echo -e "\e[37;1m[*] Payload 2 (Strings Long) [*]\e[0m"
    rg -Hn --color "'[A-Za-z0-9+/=]{32,}'" $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 2 (Strings Long) [DONE]\e[0m"

    # Busca por strings em formato hexadecimal (Payload 3)
    echo -e "\e[37;1m[*] Payload 3 (Strings Hexa) [*]\e[0m"
    rg -Hn --color "'[A-Fa-f0-9]{32,}'" $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 3 (Strings Hexa) [DONE]\e[0m"

    # Busca por URLs com dados sensíveis (Payload 4)
    echo -e "\e[37;1m[*] Payload 4 (Sensitive Urls) [*]\e[0m"
    rg -Hn --color "https?://[^\s]*[?&](token|secret|key|passphrase|salt|cipher)" $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 4 (Sensitive Urls) [DONE]\e[0m"

    # Busca por dados de configuração em strings (Payload 5)
    echo -e "\e[37;1m[*] Payload 5 (Config Data) [*]\e[0m"
    rg -Hn --color "'[A-Za-z0-9_/]{10,}'" $selected_apk | logs_out
    echo -e "\e[37;1m[*] Payload 5 (Config Data) [DONE]\e[0m"
}

function content_check() {
    echo
    verify_apks

    # Verifica se o APK foi selecionado corretamente
    if [ -z "$selected_apk" ]; then
        echo -e "\033[31;1m[-] Nenhum APK selecionado. [-]\033[0m"
        exit 1
    fi

    #-------------------------------------------
    echo -e "\e[37;1mContent Check\e[0m"

    # Busca por URLs de conteúdo
    echo -e "\e[37;1m[*] Payload 1 (Content URLs) [*]\e[0m"
    grep -Hirn "content://[a-zA-Z0-9._-]\+/[a-zA-Z0-9._-]\+" --color "$selected_apk" | logs_out
    echo -e "\e[37;1m[*] Payload 1 (Content URLs) [DONE]\e[0m"
}

function intent_check() {
    echo
    verify_apks

    # Verifica se o APK foi selecionado corretamente
    if [ -z "$selected_apk" ]; then
        echo -e "\033[31;1m[-] Nenhum APK selecionado. [-]\033[0m"
        exit 1
    fi

    #----------------------------------------------
    echo -e "\e[37;1mIntent Check\e[0m"

    # Busca por URLs relacionadas a Intents
    echo -e "\e[37;1m[*] Payload 1 (Intent URLs) [*]\e[0m"
    grep -Hirn "[a-zA-Z0-9._-]\+\.intent\.[a-zA-Z0-9._-]\+" --color "$selected_apk" | logs_out
    echo -e "\e[37;1m[*] Payload 1 (Intent URLs) [DONE]\e[0m"
}

function r.strings_check() {
    echo
    verify_apks

    # Verifica se o APK foi selecionado corretamente
    if [ -z "$selected_apk" ]; then
        echo -e "\033[31;1m[-] Nenhum APK selecionado. [-]\033[0m"
        exit 1
    fi

    #-------------------------------------------------

    default_res_dir=$(find "$selected_apk/res/values/strings.xml")
    res_dir=$(find "$selected_apk/res/values/" -name "*.xml" -type f)

    echo -e "\033[37;1m[+] Utilizar o caminho padrão (y/n): \033[0m"
    read -p "select> " default_yn

    if [[ "$default_yn" == "y" || "$default_yn" == "yes" || "$default_yn" == "Y" || "$default_yn" == "YES" ]]; then
        # Busca nos arquivos padrões
        search_files="$default_res_dir"
    elif [[ "$default_yn" == "n" || "$default_yn" == "N" || "$default_yn" == "no" || "$default_yn" == "NO" ]]; then
        i=0
        for item in $res_dir; do
            echo "[+] Resource Dir: ($i) $item [+]"
            ((i++))
        done

        echo -e "\033[37;1m[+] Selecione o arquivo strings.xml: \033[0m"
        read -p "root> " vstrings

        if [[ $vstrings =~ ^[0-9]+$ ]] && [ "$vstrings" -ge 0 ] && [ "$vstrings" -lt "$i" ]; then
            selected_strings=$(echo "$res_dir" | sed -n "$((vstrings + 1))p")
            search_files="$selected_strings"
        else
            echo -e "\033[31;1m[-] Seleção inválida. [-]\033[0m"
            exit 1
        fi
    else
        echo -e "\033[31;1m[-] Operação cancelada! [-]\033[0m"
        exit 1
    fi

    #------------------------------------------------
    # Payloads
    #------------------------------------------------

    # Payload 1: Chaves relacionadas a autenticação
    echo -e "\e[37;1m[*] Payload 1 (Auth Keys) [*]\e[0m"
    grep -HirEn "(api[-_]?key|secret|token|auth[-_]?key|apikey|access[-_]?key)" --color "$search_files" | logs_out
    echo -e "\e[37;1m[*] Payload 1 (Auth Keys) [DONE]\e[0m"

    # Payload 2: URLs com chaves como parâmetros
    echo -e "\e[37;1m[*] Payload 2 (Url+Key) [*]\e[0m"
    grep -HirEn "https?:\/\/[^\s]*[?&]key=[A-Za-z0-9]+" --color "$search_files" | logs_out
    echo -e "\e[37;1m[*] Payload 2 (Url+Key) [DONE]\e[0m"

    # Payload 3: Chaves longas em strings
    echo -e "\e[37;1m[*] Payload 3 (Long Keys) [*]\e[0m"
    grep -HirEn "['\"]([A-Za-z0-9]{20,})['\"]" --color "$search_files" | logs_out
    echo -e "\e[37;1m[*] Payload 3 (Long Keys) [DONE]\e[0m"

    # Payload 4: URLs de API com subdomínio "api."
    echo -e "\e[37;1m[*] Payload 4 (API URLs) [*]\e[0m"
    grep -HirEn "https?://api\.[a-zA-Z0-9./?=_-]*" --color "$search_files" | logs_out
    echo -e "\e[37;1m[*] Payload 4 (API URLs) [DONE]\e[0m"

    # Payload 5: URLs com endpoints de API comuns
    echo -e "\e[37;1m[*] Payload 5 (API Endpoints) [*]\e[0m"
    grep -HirEn "https?://[a-zA-Z0-9./?=_-]*(/v[0-9]+|/api/|/oauth/|/auth/|/token/|aws)" --color "$search_files" | logs_out
    echo -e "\e[37;1m[*] Payload 5 (API Endpoints) [DONE]\e[0m"

    # Payload 6: URLs genéricas
    echo -e "\e[37;1m[*] Payload 6 (Generic URLs) [*]\e[0m"
    grep -HirEn "https?://[a-zA-Z0-9./?=_-]+" --color "$search_files" | logs_out
    echo -e "\e[37;1m[*] Payload 6 (Generic URLs) [DONE]\e[0m"

    # Payload 7: URLs em arquivos smali
    echo -e "\e[37;1m[*] Payload 7 (Smali URLs) [*]\e[0m"
    grep -HirEn 'const-string [vp][0-9]+, "https?://[a-zA-Z0-9./?=_-]*api[a-zA-Z0-9./?=_-]*"' --color "$search_files" | logs_out
    echo -e "\e[37;1m[*] Payload 7 (Smali URLs) [DONE]\e[0m"

    # Payload 8: Chaves hexadecimal
    echo -e "\e[37;1m[*] Payload 8 (Hexadecimal Keys) [*]\e[0m"
    grep -HirEn 'const-string [vp][0-9]+, "([A-Fa-f0-9]{32,})"' --color "$search_files" | logs_out
    echo -e "\e[37;1m[*] Payload 8 (Hexadecimal Keys) [DONE]\e[0m"

    # Payload 9: Chaves em Base64
    echo -e "\e[37;1m[*] Payload 9 (Base64 Keys) [*]\e[0m"
    grep -HirEn 'const-string [vp][0-9]+, "([A-Za-z0-9+/=]{20,})"' --color "$search_files" | logs_out
    echo -e "\e[37;1m[*] Payload 9 (Base64 Keys) [DONE]\e[0m"

    # Payload 10: Variáveis de ambiente
    echo -e "\e[37;1m[*] Payload 10 (Environment Variables) [*]\e[0m"
    grep -HirEn 'invoke-static .* Ljava/lang/System;->getenv\(Ljava/lang/String;\)Ljava/lang/String;' --color "$search_files" | logs_out
    echo -e "\e[37;1m[*] Payload 10 (Environment Variables) [DONE]\e[0m"
}
