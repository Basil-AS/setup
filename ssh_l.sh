#!/bin/bash

# Определение имени файла для SSH ключа
SSH_KEY_PATH="$HOME/.ssh/id_rsa"

# Создание SSH ключа, если он не существует
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "Создание нового SSH ключа..."
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N ""
fi

# Запуск SSH агента, если он еще не запущен
if [ -z "$SSH_AGENT_PID" ]; then
    eval "$(ssh-agent -s)"
fi

# Добавление SSH ключа в SSH агент
ssh-add "$SSH_KEY_PATH"

# Вывод публичного ключа
cat "${SSH_KEY_PATH}.pub"
