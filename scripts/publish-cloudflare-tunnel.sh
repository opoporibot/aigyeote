#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/publish-cloudflare-tunnel.sh <tunnel-name> <hostname> [port]
# Example:
#   ./scripts/publish-cloudflare-tunnel.sh aigyeote aigyeote.example.com 8000

TUNNEL_NAME="${1:-}"
HOSTNAME="${2:-}"
PORT="${3:-8000}"
CONFIG_DIR="$HOME/.cloudflared"
CONFIG_FILE="$CONFIG_DIR/config.yml"
PID_DIR="$HOME/.aigyeote"
PID_FILE="$PID_DIR/cloudflared.pid"

if [[ -z "$TUNNEL_NAME" || -z "$HOSTNAME" ]]; then
  echo "usage: $0 <tunnel-name> <hostname> [port]" >&2
  exit 1
fi

mkdir -p "$CONFIG_DIR" "$PID_DIR"

if [[ ! -f "$CONFIG_DIR/cert.pem" ]]; then
  echo "Missing $CONFIG_DIR/cert.pem" >&2
  echo "Run: cloudflared tunnel login" >&2
  exit 1
fi

if ! lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  echo "Port $PORT is not listening. Start the local web server first." >&2
  exit 1
fi

if ! cloudflared tunnel list 2>/dev/null | grep -q "$TUNNEL_NAME"; then
  cloudflared tunnel create "$TUNNEL_NAME"
fi

TUNNEL_ID="$(cloudflared tunnel list --output json | python3 -c 'import json,sys; data=json.load(sys.stdin); name=sys.argv[1]; print(next((x["id"] for x in data if x["name"]==name), ""))' "$TUNNEL_NAME")"

if [[ -z "$TUNNEL_ID" ]]; then
  echo "Failed to resolve tunnel ID for $TUNNEL_NAME" >&2
  exit 1
fi

CRED_FILE="$CONFIG_DIR/${TUNNEL_ID}.json"

cloudflared tunnel route dns "$TUNNEL_NAME" "$HOSTNAME"

cat > "$CONFIG_FILE" <<EOF
url: http://127.0.0.1:${PORT}
tunnel: ${TUNNEL_ID}
credentials-file: ${CRED_FILE}
ingress:
  - hostname: ${HOSTNAME}
    service: http://127.0.0.1:${PORT}
  - service: http_status:404
EOF

if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  kill "$(cat "$PID_FILE")"
  sleep 1
fi

cloudflared tunnel run "$TUNNEL_NAME" > "$PID_DIR/cloudflared.out" 2>&1 &
echo $! > "$PID_FILE"

echo "Tunnel started"
echo "Hostname: https://$HOSTNAME"
echo "PID: $(cat "$PID_FILE")"
echo "Logs: $PID_DIR/cloudflared.out"
