#!/usr/bin/env bash
set -euo pipefail

# Следит за состоянием доступности NetworkManager и открывает браузер на
# странице входа, когда сеть требует регистрации (captive portal).
#
# Триггер — только connectivity=portal (не limited/unknown), чтобы не открывать
# браузер на сетях просто без интернета. Для каждого SSID страница открывается
# единожды; флаг сбрасывается, когда доступность снова full.

BROWSER="${CAPTIVE_PORTAL_BROWSER:-firefox}"
# Тот же URL, что и у NM (см. modules/aspects/networking.nix): портал
# white-листит проверочные адреса ОС (gstatic/Apple/Microsoft), поэтому
# открывать нужно домен, который точно попадёт в редирект на страницу входа.
PORTAL_URL="${CAPTIVE_PORTAL_URL:-http://nmcheck.gnome.org/check_network_status.txt}"
INTERVAL="${CAPTIVE_PORTAL_INTERVAL:-5}"

handled_ssid=""

while sleep "$INTERVAL"; do
	state="$(LC_ALL=C nmcli -t -f CONNECTIVITY general 2>/dev/null)" || continue
	ssid="$(LC_ALL=C nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | awk -F: '$2 == "802-11-wireless" { print $1; exit }')"

	if [ "$state" = "full" ]; then
		handled_ssid=""
		continue
	fi

	if [ "$state" = "portal" ] && [ -n "$ssid" ] && [ "$ssid" != "$handled_ssid" ]; then
		handled_ssid="$ssid"
		command -v notify-send >/dev/null 2>&1 &&
			notify-send -i network-wireless "Wi-Fi" "Открываю страницу входа ($ssid)"
		"$BROWSER" --new-tab "$PORTAL_URL" >/dev/null 2>&1 &
	fi
done
