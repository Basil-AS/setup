# setup

Набор небольших установочных скриптов и конфигураций.

## OpenWrt: AmneziaWG одной командой

Автоматически:

- определяет версию OpenWrt и `target/subtarget`;
- устанавливает публичный ключ подписанного AWG APK-репозитория;
- добавляет или обновляет AWG feed в `/etc/apk/repositories.d/customfeeds.list`;
- сохраняет ключ и feed при `sysupgrade`;
- выполняет `apk update`;
- устанавливает или обновляет `kmod-amneziawg`, `amneziawg-tools`, `luci-proto-amneziawg` и русскую локализацию LuCI.

Запуск на OpenWrt 25.x и новее:

```sh
wget -qO- https://raw.githubusercontent.com/Basil-AS/setup/main/openwrt/install-awg.sh | sh
```

После обновления OpenWrt достаточно снова выполнить ту же команду. Скрипт сам заменит URL feed на путь для текущей версии прошивки и платформы.

### Без русской локализации

```sh
wget -qO- https://raw.githubusercontent.com/Basil-AS/setup/main/openwrt/install-awg.sh | sh -s -- --no-i18n
```

### Только подключить репозиторий и ключ

```sh
wget -qO- https://raw.githubusercontent.com/Basil-AS/setup/main/openwrt/install-awg.sh | sh -s -- --repo-only
```

### Проверка

```sh
apk policy kmod-amneziawg amneziawg-tools luci-proto-amneziawg
```

При обновлении `kmod-amneziawg` перезагрузите роутер, чтобы ядро загрузило новую версию модуля:

```sh
reboot
```

Исходный AWG package feed: [Slava-Shchipunov/awg-openwrt](https://github.com/Slava-Shchipunov/awg-openwrt).
