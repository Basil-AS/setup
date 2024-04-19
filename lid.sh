#!/bin/bash

# Проверяем, есть ли права суперпользователя
if [ "$EUID" -ne 0 ]
  then echo "Пожалуйста, запустите как root"
  exit
fi

# Создаем резервную копию файла logind.conf
cp /etc/systemd/logind.conf /etc/systemd/logind.conf.bak

# Заменяем настройки в logind.conf
sed -i 's/^#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
sed -i 's/^HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
sed -i 's/^#HandleLidSwitchExternalPower=suspend/HandleLidSwitchExternalPower=ignore/' /etc/systemd/logind.conf
sed -i 's/^HandleLidSwitchExternalPower=suspend/HandleLidSwitchExternalPower=ignore/' /etc/systemd/logind.conf
sed -i 's/^#HandleLidSwitchDocked=suspend/HandleLidSwitchDocked=ignore/' /etc/systemd/logind.conf
sed -i 's/^HandleLidSwitchDocked=suspend/HandleLidSwitchDocked=ignore/' /etc/systemd/logind.conf

# Перезагрузка сервиса для применения изменений
systemctl restart systemd-logind.service

echo "Выключение при закрытии крышки ноутбука отключено."
