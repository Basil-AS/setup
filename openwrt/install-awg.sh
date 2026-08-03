#!/bin/sh
set -eu

AWG_BASE_URL="https://slava-shchipunov.github.io/awg-openwrt"
AWG_KEY_URL="$AWG_BASE_URL/keys/awg-openwrt-feed.pem"
AWG_KEY_FILE="/etc/apk/keys/awg-openwrt-feed.pem"
CUSTOM_FEEDS_FILE="/etc/apk/repositories.d/customfeeds.list"
SYSUPGRADE_FILE="/etc/sysupgrade.conf"

WITH_I18N=1
REPO_ONLY=0

usage() {
    cat <<'EOF'
Usage: install-awg.sh [options]

Configure the signed AmneziaWG APK feed for the current OpenWrt release
and install or update the matching AWG packages.

Options:
  --no-i18n    Do not install the Russian LuCI translation
  --repo-only  Configure the key and repository, but do not install packages
  -h, --help   Show this help
EOF
}

log() {
    printf '\033[1;32m[AWG]\033[0m %s\n' "$*"
}

fatal() {
    printf '\033[1;31m[AWG] ERROR:\033[0m %s\n' "$*" >&2
    exit 1
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --no-i18n)
            WITH_I18N=0
            ;;
        --repo-only)
            REPO_ONLY=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            fatal "Unknown option: $1"
            ;;
    esac
    shift
done

[ "$(id -u)" -eq 0 ] || fatal "Run this script as root"
command -v apk >/dev/null 2>&1 || fatal "apk was not found; OpenWrt 25.x or newer is required"
command -v wget >/dev/null 2>&1 || fatal "wget was not found"
[ -r /etc/openwrt_release ] || fatal "/etc/openwrt_release was not found"

# shellcheck disable=SC1091
. /etc/openwrt_release

VERSION="${DISTRIB_RELEASE:-}"
FULL_TARGET="${DISTRIB_TARGET:-}"

[ -n "$VERSION" ] || fatal "Could not determine the OpenWrt version"
[ -n "$FULL_TARGET" ] || fatal "Could not determine target/subtarget"

case "$VERSION" in
    2[5-9].*|[3-9][0-9].*) ;;
    *) fatal "The signed APK feed is intended for OpenWrt 25.x or newer; detected $VERSION" ;;
esac

case "$FULL_TARGET" in
    */*) ;;
    *) fatal "Unexpected target value: $FULL_TARGET" ;;
esac

TARGET="${FULL_TARGET%%/*}"
SUBTARGET="${FULL_TARGET#*/}"
FEED_URL="$AWG_BASE_URL/$VERSION/$TARGET/$SUBTARGET/packages.adb"

log "Detected OpenWrt $VERSION ($TARGET/$SUBTARGET)"
log "Using feed: $FEED_URL"

mkdir -p /etc/apk/keys /etc/apk/repositories.d

TMP_KEY="/tmp/awg-openwrt-feed.pem.$$"
TMP_FEEDS="/tmp/awg-customfeeds.$$"
trap 'rm -f "$TMP_KEY" "$TMP_FEEDS"' EXIT HUP INT TERM

log "Downloading the repository signing key"
wget -q -O "$TMP_KEY" "$AWG_KEY_URL" || fatal "Could not download the signing key"
[ -s "$TMP_KEY" ] || fatal "Downloaded signing key is empty"
grep -q '^-----BEGIN PUBLIC KEY-----$' "$TMP_KEY" || fatal "Downloaded file is not a PEM public key"
install -m 0644 "$TMP_KEY" "$AWG_KEY_FILE"

# Preserve all unrelated custom feeds and replace only this project's AWG feed.
if [ -f "$CUSTOM_FEEDS_FILE" ]; then
    grep -v '^https://slava-shchipunov\.github\.io/awg-openwrt/' "$CUSTOM_FEEDS_FILE" > "$TMP_FEEDS" || true
else
    : > "$TMP_FEEDS"
fi

{
    cat "$TMP_FEEDS"
    printf '%s\n' "$FEED_URL"
} > "$CUSTOM_FEEDS_FILE"

# Explicitly retain the custom feed and key across sysupgrade.
touch "$SYSUPGRADE_FILE"
for path in "$CUSTOM_FEEDS_FILE" "$AWG_KEY_FILE"; do
    grep -Fxq "$path" "$SYSUPGRADE_FILE" || printf '%s\n' "$path" >> "$SYSUPGRADE_FILE"
done

log "Refreshing APK indexes"
apk update

if [ "$REPO_ONLY" -eq 1 ]; then
    log "Repository configuration completed"
    exit 0
fi

set -- kmod-amneziawg amneziawg-tools luci-proto-amneziawg
[ "$WITH_I18N" -eq 0 ] || set -- "$@" luci-i18n-amneziawg-ru

log "Installing or updating: $*"
apk add --upgrade "$@"

log "Installed package versions"
for package in "$@"; do
    apk info -e "$package" >/dev/null 2>&1 && apk info -v "$package" | head -n 1 || true
done

if apk info -e kmod-amneziawg >/dev/null 2>&1; then
    log "AWG is ready. Reboot if kmod-amneziawg was upgraded while its old module was loaded."
fi
