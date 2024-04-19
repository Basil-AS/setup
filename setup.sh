#!/bin/bash

# Файл для логирования
LOGFILE="setup.log"

# Указываем базовый URL для скриптов
BASE_URL="https://raw.githubusercontent.com/Basil-AS/setup/main"

# Список скриптов для загрузки и выполнения в предложенной последовательности
declare -a scripts=(
    "lid.sh"
    "hostname.sh"
    "zsh.sh"
    "ssh.sh"
    "git.sh"
    "adguard.sh"
    "selinux.sh"
    "cockpit.sh"
)

# Функция для загрузки и выполнения скрипта с логированием
run_script() {
    echo "Загрузка и выполнение $1" | tee -a $LOGFILE
    curl -fsSL "$BASE_URL/$1" | bash 2>&1 | tee -a $LOGFILE
}

# Начало логирования
echo "Начало установки: $(date)" | tee -a $LOGFILE

# Выполнение скриптов по порядку
for script in "${scripts[@]}"; do
    run_script $script
done

# Обработка authorized_keys с логированием
echo "Добавление ключей из authorized_keys" | tee -a $LOGFILE
if [ -f "$HOME/.ssh/authorized_keys" ]; then
    cat "$BASE_URL/authorized_keys" >> "$HOME/.ssh/authorized_keys" 2>&1 | tee -a $LOGFILE
else
    curl -fsSL "$BASE_URL/authorized_keys" > "$HOME/.ssh/authorized_keys" 2>&1 | tee -a $LOGFILE
fi

# Завершение логирования
echo "Очистка завершена" | tee -a $LOGFILE
echo "Установка завершена: $(date)" | tee -a $LOGFILE
