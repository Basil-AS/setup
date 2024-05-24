#!/bin/sh

# Обновляем список пакетов и устанавливаем необходимые зависимости
opkg update && opkg install ca-certificates zsh curl git-http luci-i18n-base-ru luci-compat luci-lib-ipkg nano iperf3 openssh-sftp-server

# Устанавливаем oh-my-zsh, если не установлен
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Устанавливаем zsh по умолчанию для root пользователя
if which zsh && ! grep -q '/usr/bin/zsh' /etc/passwd; then
    sed -i -- 's:/bin/ash:'`which zsh`':g' /etc/passwd
fi

# Добавляем защиту от блокировки пользователя в /etc/rc.local, если еще не добавлена
if ! grep -q 'Revert root shell to ash if zsh is not available' /etc/rc.local; then
cat << 'EOF' >> /etc/rc.local

# Revert root shell to ash if zsh is not available
if grep -q '^root:.*:/usr/bin/zsh$' /etc/passwd && [ ! -x /usr/bin/zsh ]; then
    # zsh is root shell, but zsh was not found or not executable: revert to default ash
    [ -x /usr/bin/logger ] && /usr/bin/logger -s "Reverting root shell to ash, as zsh was not found on the system"
    sed -i -- 's:/usr/bin/zsh:/bin/ash:g' /etc/passwd
fi

EOF
fi

# Установка плагинов zsh-autosuggestions и zsh-syntax-highlighting, если не установлены
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
fi

# Настройка .zshrc для использования плагинов и изменения темы, если еще не настроены
if ! grep -q 'zsh-autosuggestions' ~/.zshrc; then
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting sudo history)/' ~/.zshrc
fi
if ! grep -q 'ZSH_THEME="af-magic"' ~/.zshrc; then
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="af-magic"/' ~/.zshrc
fi

# Установка темы luci-theme-argon, если не установлена
if ! opkg list-installed | grep -q 'luci-theme-argon'; then
    wget --no-check-certificate https://github.com/jerrykuku/luci-theme-argon/releases/download/v2.3.1/luci-theme-argon_2.3.1_all.ipk -O /tmp/luci-theme-argon_2.3.1_all.ipk
    opkg install /tmp/luci-theme-argon_2.3.1_all.ipk
fi

# Установка приложения для настройки темы luci-app-argon-config, если не установлено
if ! opkg list-installed | grep -q 'luci-app-argon-config'; then
    wget --no-check-certificate https://github.com/jerrykuku/luci-app-argon-config/releases/download/v0.9/luci-app-argon-config_0.9_all.ipk -O /tmp/luci-app-argon-config_0.9_all.ipk
    opkg install /tmp/luci-app-argon-config_0.9_all.ipk
fi

echo "Установка oh-my-zsh, дополнительных плагинов, темы luci-theme-argon и других утилит завершена. Перезагрузите устройство для применения изменений."
