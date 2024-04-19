#!/bin/bash

# Проверка на запуск скрипта от имени суперпользователя
if [ "$(id -u)" -ne 0 ]; then
    echo "Скрипт нужно запускать с правами суперпользователя (sudo)." >&2
    exit 1
fi

# Изменение имени хоста
hostnamectl set-hostname lena
echo "Имя хоста изменено на 'lena'."

# Обновление файла /etc/hosts
sed -i "s/127.0.1.1 .*/127.0.1.1 lena/" /etc/hosts
echo "Файл /etc/hosts обновлён."
