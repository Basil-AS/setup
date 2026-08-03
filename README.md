# setup

Набор небольших установочных скриптов и конфигураций.

## OpenWrt: AmneziaWG одной командой

Автоматически:

- определяет версию OpenWrt и `target/subtarget`;
- устанавливает публичный ключ подписанного AWG APK-репозитория;
- добавляет или обновляет AWG feed в `/etc/apk/repositories.d/customfeeds.list`, сохраняя остальные сторонние feed;
- сохраняет ключ и feed при `sysupgrade`;
- выполняет `apk update`;
- устанавливает или обновляет `kmod-amneziawg`, `amneziawg-tools`, `luci-proto-amneziawg` и русскую локализацию LuCI.

Запуск на OpenWrt 25.x и новее:

```sh
(tmp="$(mktemp)" && wget -O "$tmp" https://raw.githubusercontent.com/Basil-AS/setup/main/openwrt/install-awg.sh && sh "$tmp"; rc=$?; rm -f "$tmp"; exit "$rc")
```

Команда сначала полностью скачивает скрипт и запускает его только после успешной загрузки. После обновления OpenWrt достаточно снова выполнить ту же команду: URL feed будет перестроен под текущую версию прошивки и платформу.

### Без русской локализации

```sh
(tmp="$(mktemp)" && wget -O "$tmp" https://raw.githubusercontent.com/Basil-AS/setup/main/openwrt/install-awg.sh && sh "$tmp" --no-i18n; rc=$?; rm -f "$tmp"; exit "$rc")
```

### Только подключить репозиторий и ключ

```sh
(tmp="$(mktemp)" && wget -O "$tmp" https://raw.githubusercontent.com/Basil-AS/setup/main/openwrt/install-awg.sh && sh "$tmp" --repo-only; rc=$?; rm -f "$tmp"; exit "$rc")
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
