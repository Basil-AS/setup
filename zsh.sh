#!/bin/bash

# Завершить скрипт при любой ошибке
set -e

# Функция для установки необходимых пакетов
install_packages() {
    sudo $1 update
    sudo $1 install -y zsh git wget micro screenfetch
}

# Смена оболочки на Zsh
change_shell_to_zsh() {
    chsh -s $(which zsh)
}

# Установка Oh My Zsh без интерактивных запросов
install_oh_my_zsh() {
    export RUNZSH=no KEEP_ZSHRC=yes
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting sudo history)/' ~/.zshrc
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="af-magic"/' ~/.zshrc
}

# Определение операционной системы
OS=$(grep ^ID= /etc/os-release | cut -d'=' -f2 | tr -d '"')

case $OS in
    ubuntu|debian)
        install_packages "apt"
        ;;
    fedora)
        install_packages "dnf"
        ;;
    centos)
        install_packages "yum"
        ;;
    opensuse-leap|opensuse-tumbleweed)
        install_packages "zypper"
        ;;
    *)
        echo "Операционная система не поддерживается."
        exit 1
        ;;
esac

# Смена оболочки на Zsh (перед установкой Oh My Zsh)
change_shell_to_zsh

# Установка Oh My Zsh и плагинов
install_oh_my_zsh
