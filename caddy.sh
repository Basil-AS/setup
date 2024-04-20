#!/bin/bash

# Остановка при ошибке
set -e

# Установка необходимых компонентов для добавления репозитория
echo "Установка компонентов для управления репозиториями..."
sudo dnf install 'dnf-command(copr)' -y

# Добавление репозитория Caddy
echo "Добавление репозитория Caddy..."
sudo dnf copr enable @caddy/caddy -y

# Установка Caddy
echo "Установка Caddy..."
sudo dnf install caddy -y

# Настройка Caddyfile
echo "Настройка Caddyfile..."
sudo tee /etc/caddy/Caddyfile > /dev/null << 'EOF'
cp.vsbox.fun {
    reverse_proxy https://localhost:9090 {
        transport http {
            tls_insecure_skip_verify
        }
    }
    tls {
        on_demand
    }
    header {
        Strict-Transport-Security "max-age=31536000;"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        Referrer-Policy "no-referrer"
    }
}
EOF

# Перезапуск Caddy для применения настроек
echo "Перезапуск Caddy..."
sudo systemctl restart caddy

# Обновление конфигурации Cockpit
echo "Обновление конфигурации Cockpit..."
sudo mkdir -p /etc/cockpit
sudo tee /etc/cockpit/cockpit.conf > /dev/null << 'EOF'
[WebService]
Origins = https://cockpit.example.com wss://cockpit.example.com
ProtocolHeader = X-Forwarded-Proto
EOF

# Перезапуск Cockpit для применения настроек
echo "Перезапуск Cockpit..."
sudo systemctl restart cockpit

echo "Установка и настройка завершены!"
