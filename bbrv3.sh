#!/bin/bash
#
# Script para Kernel XanMod e BBRv3
# Autor: github.com/opiran-club
#
# Fornece opções para instalar pacotes necessários, configurar o kernel XanMod e BBRv3
# baixar a configuração apropriada e o programa.
#
# Arquiteturas suportadas: x86_64, amd64
# Sistemas operacionais suportados: Ubuntu 18.04/20.04/22.04, Debian 10/11
#
# Uso:
#   - Execute o script com privilégios de root.
#   - Siga os prompts na tela para instalar, configurar ou desinstalar
#
# Para mais informações e atualizações, visite github.com/opiran-club e @opiranclub no Telegram.
#
# Isenção de responsabilidade:
# Este script não vem com garantias ou garantias. Use-o por sua conta e risco.

CYAN="\e[96m"
GREEN="\e[92m"
YELLOW="\e[93m"
RED="\e[91m"
BLUE="\e[94m"
MAGENTA="\e[95m"
NC="\e[0m"

ask_reboot() {
    echo ""
    echo -e "\n ${YELLOW}Reiniciar agora? (Recomendado) ${GREEN}[y/n]${NC}"
    echo ""
    read reboot
    case "$reboot" in
        [Yy])
            systemctl reboot || echo -e "${RED}Falha ao reiniciar.${NC}"
            ;;
        *)
            return
            ;;
    esac
    exit
}

press_enter() {
    echo -e "\n ${RED}Pressione Enter para continuar... ${NC}"
    read
}

check_dependencies() {
    local missing_deps=()
    for dep in awk wget gpg apt-get; do
        if ! command -v $dep &> /dev/null; then
            missing_deps+=($dep)
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${RED}Dependências ausentes: ${missing_deps[@]}.${NC} Por favor, instale-as e tente novamente."
        exit 1
    fi
}

cpu_level() {
    os=""
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        case $ID in
            "debian" | "ubuntu")
                os="Debian/Ubuntu"
                ;;
            "centos")
                os="CentOS"
                ;;
            "fedora")
                os="Fedora"
                ;;
            "arch")
                os="Arch"
                ;;
            *)
                os="Desconhecido"
                ;;
        esac
    fi

    cpu_support_info=$(wget -qO - https://raw.githubusercontent.com/PhoenixxZ2023/bbrv3/master/checkcpu.sh | awk -f -) || {
        echo -e "${RED}Falha ao verificar suporte da CPU.${NC}"
        return 1
    }

    if [[ $cpu_support_info == "CPU suporta x86-64-v"* ]]; then
        cpu_support_level=${cpu_support_info#CPU suporta x86-64-v}
        echo -e "${MAGENTA}Nível atual da CPU:${GREEN} x86-64 Nível $cpu_support_level${NC}"
        return $cpu_support_level
    else
        echo -e "${RED}O nível da CPU ou o SO não é suportado pelo kernel XanMod e não pode ser instalado.${NC}"
        return 0
    fi
}

install_xanmod() {
    clear
    cpu_support_info=$(wget -qO - https://raw.githubusercontent.com/opiran-club/VPS-Optimizer/main/checkcpu.sh | awk -f -) || {
        echo -e "${RED}Falha ao verificar suporte da CPU.${NC}"
        return 1
    }

    if [[ $cpu_support_info == "CPU suporta x86-64-v"* ]]; then
        cpu_support_level=${cpu_support_info#CPU suporta x86-64-v}
        echo -e "${CYAN}Nível atual da CPU: x86-64 Nível $cpu_support_level${NC}"
    else
        echo -e "${RED}O nível da CPU ou o SO não é suportado pelo kernel XanMod e não pode ser instalado.${NC}"
        return 1
    fi

    echo -e "${YELLOW}Instalando o kernel XanMod${NC}"
    echo -e "${CYAN}Site oficial do Kernel: https://xanmod.org${NC}"
    echo -e "${CYAN}SourceForge: https://sourceforge.net/projects/xanmod/files/releases/lts/${NC}"
    echo ""

    echo -ne "${YELLOW}Deseja continuar com o download e instalação do kernel XanMod? [y/n]:${NC}   "
    read continue

    if [[ $continue == [Yy] ]]; then
        wget -qO - https://gitlab.com/afrd.gpg | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg || {
            echo -e "${RED}Falha ao adicionar a chave GPG do XanMod.${NC}"
            return 1
        }
        echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-release.list || {
            echo -e "${RED}Falha ao adicionar o repositório XanMod.${NC}"
            return 1
        }

        temp_folder=$(mktemp -d)
        cd $temp_folder || {
            echo -e "${RED}Falha ao mudar para o diretório temporário.${NC}"
            return 1
        }

        case $cpu_support_level in
            1)
                apt-get update || { echo -e "${RED}Falha ao atualizar a lista de pacotes.${NC}"; return 1; }
                apt-get install linux-xanmod-x64v1 -y || { echo -e "${RED}Falha ao instalar o kernel XanMod versão 1.${NC}"; return 1; }
                ;;
            2)
                apt-get update || { echo -e "${RED}Falha ao atualizar a lista de pacotes.${NC}"; return 1; }
                apt-get install linux-xanmod-x64v2 -y || { echo -e "${RED}Falha ao instalar o kernel XanMod versão 2.${NC}"; return 1; }
                ;;
            3)
                apt-get update || { echo -e "${RED}Falha ao atualizar a lista de pacotes.${NC}"; return 1; }
                apt-get install linux-xanmod-x64v3 -y || { echo -e "${RED}Falha ao instalar o kernel XanMod versão 3.${NC}"; return 1; }
                ;;
            4)
                apt-get update || { echo -e "${RED}Falha ao atualizar a lista de pacotes.${NC}"; return 1; }
                apt-get install linux-xanmod-x64v4 -y || { echo -e "${RED}Falha ao instalar o kernel XanMod versão 4.${NC}"; return 1; }
                ;;
            *)
                echo -e "${RED}Seu CPU não é suportado pelo kernel XanMod e não pode ser instalado.${NC}"
                return 1
                ;;
        esac

        echo -e "${GREEN}O kernel XanMod foi instalado com sucesso.${NC}"
        press_enter
        sleep 0.5
        clear
        echo -e "${GREEN}Atualizando o GRUB ${NC}"
        echo ""

        echo -ne "${YELLOW}Você precisa atualizar a configuração do GRUB? (y/n) [Padrão: y]:${NC}    "
        read grub

        case $grub in
            [Yy])
                update-grub || { echo -e "${RED}Falha ao atualizar o GRUB.${NC}"; return 1; }
                echo -e "${GREEN}A configuração do GRUB foi atualizada.${NC}"
                ;;
            [Nn])
                echo -e "${RED}Não é recomendado, mas a otimização foi abortada.${NC}"
                ;;
            *)
                echo -e "${RED}Opção inválida, pulando atualização da configuração do GRUB.${NC}"
                ;;
        esac
    else
        echo -e "${RED}Falha na instalação do kernel XanMod.${NC}"
    fi
}

uninstall_xanmod() {
    clear
    current_kernel_version=$(uname -r)

    if [[ $current_kernel_version == *-xanmod* ]]; then
        echo -e "${CYAN}Kernel atual: ${GREEN}$current_kernel_version${NC}"
        echo -e "${RED}Desinstalando o Kernel XanMod...${NC}"
        echo ""

        echo -ne "${GREEN}Deseja desinstalar o kernel XanMod e restaurar o kernel original? (y/n): ${NC}"
        read confirm

        if [[ $confirm == [yY] ]]; then
            echo -e "${GREEN}Desinstalando o kernel XanMod e restaurando o kernel original...${NC}"
            for i in $(seq 1 4); do
                apt-get purge linux-xanmod-x64v$i -y || { echo -e "${RED}Falha ao remover o kernel XanMod versão $i.${NC}"; return 1; }
            done
            apt-get update || { echo -e "${RED}Falha ao atualizar a lista de pacotes.${NC}"; return 1; }
            apt-get autoremove -y || { echo -e "${RED}Falha ao remover pacotes não utilizados.${NC}"; return 1; }
            update-grub || { echo -e "${RED}Falha ao atualizar o GRUB.${NC}"; return 1; }

            echo -e "${GREEN}O kernel XanMod foi desinstalado e o kernel original foi restaurado.${NC}"
            echo -e "${GREEN}A configuração do GRUB foi atualizada. Por favor, reinicie para que as alterações tenham efeito.${NC}"
        else
            echo -e "${RED}Operação de desinstalação cancelada.${NC}"
        fi
    else
        echo -e "${RED}O kernel atual não é o kernel XanMod e a operação de desinstalação não pode ser realizada.${NC}"
    fi
}

bbrv3() {
    clear
    echo ""
    echo -e "${YELLOW}Tem certeza de que deseja otimizar os parâmetros do kernel para melhor desempenho de rede? (y/n): ${NC}${GREEN}   "
    read optimize_choice
    echo -e "${NC}"

    case $optimize_choice in
        y|Y)
            clear
            echo -e "${YELLOW}Fazendo backup da configuração original dos parâmetros do kernel... ${NC}"
            cp /etc/sysctl.conf /etc/sysctl.conf.bak || { echo -e "${RED}Falha ao fazer backup do sysctl.conf.${NC}"; return 1; }
            echo -e "${YELLOW}Otimizando os parâmetros do kernel para melhor desempenho de rede... ${NC}"

            cat <<EOL >> /etc/sysctl.conf
# Otimização BBRv3 para Melhor Desempenho de Rede
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = bbr
EOL

            sysctl -p || {
                echo -e "${RED}Otimização dos parâmetros do kernel falhou. Restaurando a configuração original...${NC}"
                mv /etc/sysctl.conf.bak /etc/sysctl.conf
                return 1
            }
            echo -e "${GREEN}A otimização dos parâmetros do kernel para melhor desempenho de rede foi bem-sucedida.${NC}"
            ;;
        n|N)
            echo -e "${RED}Otimização dos parâmetros do kernel cancelada.${NC}"
            ;;
        *)
            echo -e "${RED}Entrada inválida. Otimização cancelada.${NC}"
            ;;
    esac
}

check_dependencies

while true; do
    linux_version=$(awk -F= '/^PRETTY_NAME=/{gsub(/"/, "", $2); print $2}' /etc/os-release)
    kernel_version=$(uname -r)
    tg_title="https://t.me/OPIran-Official"
    yt_title="youtube.com/@opiran-inistitute"
    clear
    logo
    echo -e "\e[93m╔═══════════════════════════════════════════════╗\e[0m"  
    echo -e "\e[93m║            \e[96mBBRv3 usando kernel xanmod        \e[93m║\e[0m"   
    echo -e "\e[93m╠═══════════════════════════════════════════════╣\e[0m"
    echo ""
    echo -e "${CYAN}   ${tg_title}   ${NC}"
    echo -e "${CYAN}   ${yt_title}   ${NC}"
    echo ""
    printf "\e[93m+-----------------------------------------------+\e[0m\n" 
    echo ""
    echo -e "${MAGENTA}Informações sobre o Linux：${GREEN}${linux_version}${NC}"
    echo -e "${MAGENTA}Informações sobre o Kernel：${GREEN}${kernel_version}${NC}"
    cpu_level
    echo ""
    echo -e "${RED} !! DICA !! ${NC}"
    echo ""
    echo -e "${CYAN}SO Suportado: ${GREEN} Ubuntu / Debian ${NC}"
    echo -e "${CYAN}Nível da CPU suportado ${GREEN} [1/2/3/4] ${NC}"
    echo ""
    printf "\e[93m+-----------------------------------------------+\e[0m\n" 
    echo ""
    echo -e "${GREEN} 1) ${NC} Instalar o kernel XanMod & BBRv3 & configuração do GRUB ${NC}"
    echo -e "${GREEN} 2) ${NC} Desinstalar o kernel XanMod e restaurar ao padrão ${NC}"
    echo ""
    echo -e "${GREEN} 3) ${NC} Sair do menu${NC}"
    echo ""
    echo -ne "${GREEN}Selecione uma opção: ${NC}  "
    read choice

    case $choice in
        1)
            install_xanmod
            bbrv3
            ask_reboot
            ;;
        2)
            uninstall_xanmod
            ask_reboot
            ;;
        3)
            echo "Saindo..."
            menu
            ;;
        *)
            echo -e "${RED}Escolha inválida. Por favor, insira uma opção válida.${NC}"
            ;;
    esac

    echo -e "\n${RED}Pressione Enter para continuar... ${NC}"
    read
done
