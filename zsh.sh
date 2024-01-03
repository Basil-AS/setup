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
        sudo apt install -y $1
    elif [[ -x "$(command -v dnf)" ]]; then
        sudo dnf install -y $1
    elif [[ -x "$(command -v zypper)" ]]; then
        sudo zypper install -y $1
    elif [[ -x "$(command -v pacman)" ]]; then
        sudo pacman -S --noconfirm $1
    elif [[ -x "$(command -v apk)" ]]; then
        sudo apk add $1
    else
        echo "Не удалось найти подходящий пакетный менеджер."
        exit 1
    fi
}

# Проверка и установка пакетов
install_packages() {
    for package in zsh screenfetch htop; do
        echo "Устанавливаю $package..."
        install_package $package
        if [ $? -ne 0 ]; then
            echo "Ошибка при установке $package"
            exit 1
        fi
    done
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

install_packages

# Основная логика скрипта
check_required_tools
interactive_mode
install_oh_my_zsh

# Смена оболочки на Zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Меняю оболочку на Zsh..."
    chsh -s $(which zsh)
fi

# Удаление временных файлов
echo "Удаляю временные файлы..."
rm -rf /tmp/* || true
