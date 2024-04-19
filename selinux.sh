#!/bin/bash

# Проверка на запуск скрипта от имени суперпользователя
if [ "$(id -u)" -ne 0 ]; then
    echo "Скрипт нужно запускать с правами суперпользователя (sudo)." >&2
    exit 1
fi

# Проверка наличия SELinux
if ! selinuxenabled; then
    echo "SELinux не включён на вашей системе."
    exit 1
fi

# Отключение SELinux
setenforce 0
if [ $? -ne 0 ]; then
    echo "Не удалось временно отключить SELinux."
else
    echo "SELinux временно отключён."
fi

# Постоянное отключение SELinux
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
sed -i 's/^SELINUX=permissive/SELINUX=disabled/' /etc/selinux/config
echo "SELinux постоянно отключён."
