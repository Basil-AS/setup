#!/bin/bash

# Проверка на запуск скрипта от имени суперпользователя
if [ "$(id -u)" -ne 0 ]; then
    echo "Скрипт нужно запускать с правами суперпользователя (sudo)." >&2
    exit 1
fi

# Путь к файлу disallowed-users
FILE="/etc/cockpit/disallowed-users"

# Проверяем, существует ли файл
if [ -f "$FILE" ]; then
    # Удаление записи root из файла disallowed-users
    sed -i '/root/d' $FILE
    echo "Запись о пользователе root удалена из файла $FILE."
else
    echo "Файл $FILE не найден. Убедитесь, что Cockpit установлен."
fi
