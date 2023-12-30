#!/bin/bash

# Завершить скрипт при любой ошибке
set -e

# Функция для установки необходимых пакетов
install_packages() {
    sudo $1 update
    sudo $1 install -y zsh git wget curl micro screenfetch
}

# Установка Oh My Zsh без интерактивных запросов
install_oh_my_zsh() {
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    # Добавление плагинов и темы в .zshrc
    echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting sudo history)" >> ~/.zshrc
    echo "ZSH_THEME=\"af-magic\"" >> ~/.zshrc
}

# Определение операционной системы и установка пакетов
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

# Установка Oh My Zsh и плагинов
install_oh_my_zsh

# Смена оболочки на Zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s $(which zsh)
fi

# Применение изменений
source ~/.zshrc
