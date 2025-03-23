#!/usr/bin/env bash
#-----------------------------
# Root Testing
#-----------------------------
if [[ "$(id -u)" -ne 0 ]];then
    echo -e "\e[37;1mPlease, run this program as root!\e[0m"
    echo -e "\e[37;1mHelp: sudo bash main.sh or sudo ./main.sh\e[0m"
    exit 1
fi

#------------------------------------
# Banner
#------------------------------------
function banner1(){
    figlet Hardcode Tool
    echo -e "\e[33;1mGithub: @Pauloxc6 | \t $(date) \e[0m"
}

#----------------------------
# Var
#----------------------------

#-----------------------------------
# Functions
#-----------------------------------
if [ -f ./src/includes/func.sh ] && [ -r ./src/includes/func.sh ]; then
    . ./src/includes/func.sh
else
    echo -e "\e[1;31m[-] Error ao carregar o arquivo func.sh! [-]\e[0m"
    exit 1
fi

function help() {
    echo -e "Help Menu: "
    echo -e ""
    echo -e "\t \e[37;1mhelp        | Help Menu"
    echo -e "\t \e[37;1mexit        | Exit the program"
    echo -e "\t \e[37;1mclear       | Clean the screen"
    echo -e "\t \e[37;1mback        | Go back to the root"
    echo -e "\t \e[37;1mbanner      | Activate the Banner"
    echo -e "\t \e[37;1mlist        | List Apks"
    echo -e "\e[0m"
}

function debug() {
    echo "Teste"
}

#----------------------------
# Main
#----------------------------
while true ;do

    banner1

    #----------------------------
    # Menu
    #----------------------------
    echo -e "\e[37;1mMenu: "
    echo -e "\t \e[37;1m1. Apk File"
    echo -e "\t \e[37;1m2. Remove Apk"
    echo -e "\t \e[37;1m3. Check"
    echo -e "\t \e[37;1m4. View Logs"
    echo -e "\t \e[37;1m0. Exit"

    echo -e "\e[0m"

    read -p "# " opt

    # Testing
    case $opt in

        1)
            echo -e "\e[37;1m"
            read -p "[+] File (app.apk): " apk_file
            apk_name=$(basename "$apk_file" .apk)
            output_decompiler=$(apktool d -f -o apks_extract/"$apk_name"-plain "$apk_file");;

        2)
            remove_apks ;;

        3)
            ./src/check.sh ;;

        4)
            view_logs 
            less $selected_log ;;

        #-----------------------------------------
       
        help)
            help ;;

        exit|0)
            echo -e "\e[32;1m[*] Exiting ..... [*]\n\e[0m"
            exit 1 ;;

        clear)
            clear ;;

        back)
            ./main.sh ;;

        banner)
            banner1 ;;

        version) 
            echo ""
            echo -e "\e[37;1mVersion: 1.0\e[0m" 
            echo "" ;;

        list)
            # Encontra os diretórios dentro de 'apks_extract'
            out=$(find $PWD/apks_extract -mindepth 1 -maxdepth 1 -type d)

            # Lista os diretórios encontrados
            i=0
            for item in $out; do
                echo -e "\033[37;1m[+] File [\033[33;1m$i\033[37;1m]: \033[33;1m$item \033[37;1m[+]\033[0m"
                ((i++))
            done
        ;;
        
        *)
            echo -e "\e[31;1m[*] Error in the program! [*]\n\e[0m"
            sleep 1
            exit 1 ;;

    esac

done

#----------------------------
#exit
#----------------------------
echo -e "\e[1;77m[*] Exiting ..... [*]\n\e[1;0m"
sleep 1
exit 0
