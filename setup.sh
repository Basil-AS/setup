#!/bin/bash

# Указываем базовый URL для скриптов
BASE_URL="https://raw.githubusercontent.com/Basil-AS/setup/main"

# Список скриптов для загрузки и выполнения в предложенной последовательности
declare -a scripts=(
    "lid.sh"
    "hostname.sh"
    "ssh.sh"
    "git.sh"
    "zsh.sh"
    "adguard.sh"
    "selinux.sh"
    "cockpit.sh"
)

# Функция для загрузки и выполнения скрипта
run_script() {
    echo "Загрузка и выполнение $1"
    curl -fsSL "$BASE_URL/$1" | bash
}

# Выполнение скриптов по порядку
for script in "${scripts[@]}"; do
    run_script $script
done

# Обработка authorized_keys
echo "Добавление ключей из authorized_keys"
if [ -f "$HOME/.ssh/authorized_keys" ]; then
    cat "$BASE_URL/authorized_keys" >> "$HOME/.ssh/authorized_keys"
else
    curl -fsSL "$BASE_URL/authorized_keys" > "$HOME/.ssh/authorized_keys"
fi

# Удаление всех загруженных файлов (очистка)
echo "Очистка завершена"
