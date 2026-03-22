#!/bin/sh
set -e

: "${QBIT_URL:=http://localhost:8080}"
: "${GLUETUN_URL:=http://localhost:8000}"
: "${POLL_INTERVAL:=30}"

# Required vars — fail fast if missing
if [ -z "$QBIT_USER" ] || [ -z "$QBIT_PASS" ] || [ -z "$GLUETUN_USER" ] || [ -z "$GLUETUN_PASS" ]; then
  echo "ERROR: QBIT_USER, QBIT_PASS, GLUETUN_USER, and GLUETUN_PASS must be set."
  exit 1
fi

CURRENT_PORT=0

echo "Starting qBittorrent port updater..."
echo "  qBittorrent: $QBIT_URL"
echo "  Gluetun:     $GLUETUN_URL"
echo "  Poll every:  ${POLL_INTERVAL}s"

while true; do
  echo "Polling Gluetun for forwarded port..."

  NEW_PORT=$(curl -sf -u "$GLUETUN_USER:$GLUETUN_PASS" "$GLUETUN_URL/v1/portforward" | jq -r '.port')
  echo "Parsed port: $NEW_PORT"

  if [ -n "$NEW_PORT" ] && [ "$NEW_PORT" != "0" ] && [ "$NEW_PORT" != "$CURRENT_PORT" ]; then
    echo "Port changed: $CURRENT_PORT -> $NEW_PORT"

    LOGIN_RESP=$(curl -sf -c /tmp/qbit_cookies.txt \
      --data-urlencode "username=$QBIT_USER" \
      --data-urlencode "password=$QBIT_PASS" \
      "$QBIT_URL/api/v2/auth/login")
    echo "Login response: $LOGIN_RESP"

    if [ "$LOGIN_RESP" != "Ok." ]; then
      echo "WARNING: Login may have failed, proceeding anyway..."
    fi

    UPDATE_RESP=$(curl -sf -b /tmp/qbit_cookies.txt \
      --data "json={\"listen_port\":$NEW_PORT}" \
      "$QBIT_URL/api/v2/app/setPreferences")
    echo "Update response: $UPDATE_RESP"

    CURRENT_PORT=$NEW_PORT
    echo "qBittorrent listening port updated to $NEW_PORT"
  else
    echo "No port change detected (current: $CURRENT_PORT)"
  fi

  sleep "$POLL_INTERVAL"
done