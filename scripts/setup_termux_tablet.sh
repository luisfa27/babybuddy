#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=================================================="
echo "  Baby Buddy Ocean — Instalacao no Tablet Termux"
echo "=================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

echo "[1/6] Atualizando pacotes do Termux..."
pkg update -y
pkg install -y python python-pillow git libjpeg-turbo zlib libffi openssl

echo "[2/6] Criando ambiente virtual (.venv)..."
if [ ! -d ".venv" ]; then
    python -m venv --system-site-packages .venv
fi
source .venv/bin/activate

echo "[3/6] Instalando dependencias Python (sem psycopg2)..."
pip install --upgrade pip
pip install -r requirements-tablet.txt

echo "[4/6] Configurando arquivo .env..."
if [ ! -f ".env" ]; then
    cat > .env << 'EOF'
DJANGO_SETTINGS_MODULE=babybuddy.settings.development
DEBUG=True
ALLOWED_HOSTS=*
LANGUAGE_CODE=pt-BR
TIME_ZONE=America/Sao_Paulo
EOF
fi

echo "[5/6] Preparando arquivos estaticos e banco de dados SQLite..."
mkdir -p babybuddy/static
cp -r static/babybuddy babybuddy/static/
python manage.py migrate
python manage.py createcachetable || true

echo "[6/6] Dando permissao de execucao ao script de inicializacao..."
chmod +x "$SCRIPT_DIR/start_tablet_server.sh"

echo ""
echo "=================================================="
echo "  Instalacao concluida!"
echo "  Para iniciar o servidor no Tablet, execute:"
echo "    bash scripts/start_tablet_server.sh"
echo "=================================================="
