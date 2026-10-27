#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_FILE="$SCRIPT_DIR/test-locations.json"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

check_adb() {
    if ! command -v adb &> /dev/null; then
        log_error "adb no está instalado."
        exit 1
    fi
    if ! adb devices | grep -q "device$"; then
        log_error "No hay dispositivo Android conectado."
        exit 1
    fi
    log_ok "Dispositivo Android detectado"
}

PACKAGE_NAME="$(jq -r '.settings.packageName' "$CONFIG_FILE" 2>/dev/null || echo 'net.osmand')"
MAP_PATH="$(jq -r '.settings.mapPath' "$CONFIG_FILE" 2>/dev/null || echo '/sdcard/Android/data/net.osmand/files')"

echo "========================================"
echo "  CleanOsmand - Setup Mapa de Prueba"
echo "========================================"
echo ""

check_adb

log_info "Creando directorios necesarios en el dispositivo..."
adb shell "mkdir -p $MAP_PATH"
adb shell "mkdir -p $MAP_PATH/rendering"

log_info ""
log_info "Opciones para obtener un mapa de prueba:"
echo ""
echo "  1. Descargar desde OsmAnd en el móvil (recomendado):"
echo "     - Abre OsmAnd → Menú → Descargar mapas"
echo "     - Busca 'España' o descarga una región pequeña"
echo "     - O descarga directamente 'Andorra' (~2MB, ideal para pruebas)"
echo ""
echo "  2. Descargar .obf precompilado (alternativa):"
echo "     - Andorra: https://download.osmand.net/download?standard=yes&file=Andorra_europe_2.obf"
echo "     - Mónaco:  https://download.osmand.net/download?standard=yes&file=Monaco_europe_2.obf"
echo ""
echo "  3. Copiar manualmente vía USB/MTP a:"
echo "     $MAP_PATH/"
echo ""

log_info "Después de tener el mapa, ejecuta:"
echo "  ./scripts/preview/generate-snapshots.sh"
echo ""

log_info "Para ver qué mapas tienes instalados:"
adb shell "ls -lh $MAP_PATH/*.obf 2>/dev/null || echo '  (ningún mapa .obf encontrado)'"
