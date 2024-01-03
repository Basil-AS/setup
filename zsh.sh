#!/bin/bash

# Функция проверки наличия необходимых утилит
check_required_tools() {
    for tool in curl git wget; do
        if ! command -v $tool &> /dev/null; then
            echo "Требуется $tool, но он не установлен. Устанавливаю..."
            install_package $tool
        fi
    done
}

# Функция установки пакетов
install_package() {
    if [[ -x "$(command -v apt)" ]]; then
        sudo apt install -y $1 || handle_install_error $1
    elif [[ -x "$(command -v dnf)" ]]; then
        sudo dnf install -y $1 || handle_install_error $1
    elif [[ -x "$(command -v zypper)" ]]; then
        sudo zypper install -y $1 || handle_install_error $1
    elif [[ -x "$(command -v pacman)" ]]; then
        sudo pacman -S --noconfirm $1 || handle_install_error $1
    elif [[ -x "$(command -v apk)" ]]; then
        sudo apk add $1 || handle_install_error $1
    else
        echo "Не удалось найти подходящий пакетный менеджер."
        exit 1
    fi
}

# Обработка ошибки установки
handle_install_error() {
    local package=$1
    echo "Ошибка при установке $package."
    read -p "Хотите добавить сторонние репозитории для установки $package? (y/n) " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        if [[ -x "$(command -v dnf)" ]]; then
            echo "Добавление репозитория EPEL..."
            sudo dnf install -y epel-release && sudo dnf install -y "$package"
        else
            echo "Для вашего дистрибутива добавление сторонних репозиториев не предусмотрено."
        fi
    else
        echo "Пропускаю установку $package."
    fi
}

# Установка Oh My Zsh без интерактивных запросов
install_oh_my_zsh() {
    echo "Устанавливаю Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    if [ $? -ne 0 ]; then
        echo "Ошибка при установке Oh My Zsh"
        exit 1
    fi
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting sudo history)/' ~/.zshrc
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="af-magic"/' ~/.zshrc
}

# Интерактивный режим
interactive_mode() {
    read -p "Хотите установить дополнительные утилиты? (y/n) " answer
    if [ "$answer" != "${answer#[Yy]}" ]; then
        install_packages
    fi
}

# Проверка и установка пакетов
install_packages() {
    for package in zsh screenfetch htop neofetch util-linux; do
        echo "Устанавливаю $package..."
        install_package $package
    done
}

# Основная логика скрипта
check_required_tools
interactive_mode
install_oh_my_zsh

# Проверка наличия и смена оболочки на Zsh
if ! command -v chsh &> /dev/null; then
    echo "Команда chsh не найдена. Устанавливаю util-linux..."
    install_package util-linux
fi

if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Меняю оболочку на Zsh..."
    chsh -s $(which zsh) || echo "Не удалось изменить оболочку. Пожалуйста, смените её вручную."
fi
