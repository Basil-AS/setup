#!/bin/bash

declare -A operation_status
operation_status["curl"]=0
operation_status["git"]=0
operation_status["wget"]=0
operation_status["zsh"]=0
operation_status["screenfetch"]=0
operation_status["htop"]=0
operation_status["neofetch"]=0
operation_status["util-linux"]=0
operation_status["oh-my-zsh"]=0
operation_status["chsh"]=0

# Функция проверки наличия необходимых утилит
check_required_tools() {
    for tool in curl git wget; do
        if ! command -v $tool &> /dev/null; then
            echo "Требуется $tool, но он не установлен. Устанавливаю..."
            install_package $tool
            operation_status[$tool]=$?
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
        return 1
    fi
    return $?
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
            return 1
        fi
    else
        echo "Пропускаю установку $package."
        return 1
    fi
    return 0
}

# Установка Oh My Zsh без интерактивных запросов
install_oh_my_zsh() {
    echo "Устанавливаю Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    if [ $? -ne 0 ]; then
        echo "Ошибка при установке Oh My Zsh"
        return 1
    fi
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting sudo history)/' ~/.zshrc
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="af-magic"/' ~/.zshrc
    return 0
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
        operation_status[$package]=$?
    done
}

# Основная логика скрипта
check_required_tools
interactive_mode
install_oh_my_zsh
operation_status["oh-my-zsh"]=$?

# Проверка наличия и смена оболочки на Zsh
if ! command -v chsh &> /dev/null; then
    echo "Команда chsh не найдена. Устанавливаю util-linux..."
    install_package util-linux
fi

if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Меняю оболочку на Zsh..."
    if ! chsh -s $(which zsh) &> /dev/null; then
        echo "Не удалось изменить оболочку через chsh."
        operation_status["chsh"]=1
    else
        operation_status["chsh"]=0
    fi
else
    operation_status["chsh"]=0
fi

# Отчет об успешности операций
echo "Отчет о выполнении скрипта:"
for key in "${!operation_status[@]}"; do
    if [ ${operation_status[$key]} -eq 0 ]; then
        echo "$key: Успешно"
    else
        echo "$key: Не удалось"
    fi
done
