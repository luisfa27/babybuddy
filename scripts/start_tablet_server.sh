#!/data/data/com.termux/files/usr/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

# Mantem o processador acordado para o Android nao suspender o servidor
if command -v termux-wake-lock >/dev/null 2>&1; then
    termux-wake-lock || true
fi

if [ -d ".venv" ]; then
    source .venv/bin/activate
fi

# Detecta IPs do Wi-Fi local e do Tailscale (se instalado)
WIFI_IP=$(ip -4 addr show wlan0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n 1)
if [ -z "$WIFI_IP" ]; then
    WIFI_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
fi
TAILSCALE_IP=$(ip -4 addr show tun0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n 1)

echo "=================================================="
echo "  Baby Buddy Ocean — Servidor do Tablet Online"
echo "=================================================="
echo "  No proprio Tablet:     http://127.0.0.1:8000"
if [ -n "$WIFI_IP" ]; then
    echo "  No Android / iPhone (Wi-Fi): http://${WIFI_IP}:8000"
fi
if [ -n "$TAILSCALE_IP" ]; then
    echo "  Fora de casa (Tailscale):    http://${TAILSCALE_IP}:8000"
fi
echo "=================================================="
echo "  Pressione Ctrl+C para encerrar o servidor."
echo ""

exec python manage.py runserver 0.0.0.0:8000 --noreload
