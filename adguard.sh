#!/bin/bash

# Automated install (Linux/Unix/MacOS/FreeBSD/OpenBSD)
# To install with wget run the following command:
wget --no-verbose -O - https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v

# Проверяем, запущен ли скрипт от имени суперпользователя
if [ "$(id -u)" -ne 0 ]; then
    echo "Скрипт нужно запускать с правами суперпользователя (sudo)." >&2
    exit 1
fi

# Создание необходимой директории
sudo mkdir -p /etc/systemd/resolved.conf.d

# Создание файла конфигурации AdGuard Home
cat <<EOF > /etc/systemd/resolved.conf.d/adguardhome.conf
[Resolve]
DNS=127.0.0.1
DNSStubListener=no
EOF

# Обновление символической ссылки для resolv.conf
sudo mv /etc/resolv.conf /etc/resolv.conf.backup
sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

# Перезапуск systemd-resolved
sudo systemctl reload-or-restart systemd-resolved

echo "Конфигурация обновлена. systemd-resolved изменён и AdGuard Home установлен."
