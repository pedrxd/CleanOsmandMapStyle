#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_FILE="$SCRIPT_DIR/test-locations.json"
RENDER_XML="$REPO_ROOT/src/rendering/CleanOsmand.render.xml"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
OUTPUT_DIR="$REPO_ROOT/previews/$TIMESTAMP"

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
        log_error "adb no está instalado. Instálalo con: sudo apt install adb (Linux) o brew install android-platform-tools (Mac)"
        exit 1
    fi
    if ! adb devices | grep -q "device$"; then
        log_error "No hay ningún dispositivo Android conectado. Conecta el móvil con USB y activa la depuración USB."
        exit 1
    fi
    log_ok "Dispositivo Android detectado"
}

check_dependencies() {
    local missing=()
    command -v jq &> /dev/null || missing+=("jq")
    command -v python3 &> /dev/null || missing+=("python3")
    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Faltan dependencias: ${missing[*]}"
        log_info "Instálalas con: sudo apt install ${missing[*]} (Linux) o brew install ${missing[*]} (Mac)"
        exit 1
    fi
}

read_config() {
    PACKAGE_NAME="$(jq -r '.settings.packageName' "$CONFIG_FILE")"
    RENDERING_PATH="$(jq -r '.settings.renderingPath' "$CONFIG_FILE")"
    MAP_PATH="$(jq -r '.settings.mapPath' "$CONFIG_FILE")"
    OBF_FILE="$(jq -r '.settings.obfFile' "$CONFIG_FILE")"
    SCREENSHOT_DELAY="$(jq -r '.settings.screenshotDelay' "$CONFIG_FILE")"
    LOCATIONS_COUNT="$(jq '.locations | length' "$CONFIG_FILE")"
}

deploy_style() {
    log_info "Desplegando estilo CleanOsmand al dispositivo..."
    adb shell "mkdir -p $RENDERING_PATH"
    adb push "$RENDER_XML" "$RENDERING_PATH/CleanOsmand.render.xml"
    log_ok "Estilo desplegado en $RENDERING_PATH/CleanOsmand.render.xml"
}

check_map() {
    log_info "Verificando mapa $OBF_FILE..."
    if adb shell "[ -f $MAP_PATH/$OBF_FILE ]" 2>/dev/null; then
        log_ok "Mapa encontrado: $OBF_FILE"
    else
        log_warn "Mapa no encontrado: $OBF_FILE"
        log_info "Descárgalo desde OsmAnd en el móvil, o cámbialo en test-locations.json"
        log_info "Ruta esperada: $MAP_PATH/$OBF_FILE"
    fi
}

restart_osmand() {
    log_info "Reiniciando OsmAnd..."
    adb shell "am force-stop $PACKAGE_NAME" 2>/dev/null || true
    sleep 2
    adb shell "monkey -p $PACKAGE_NAME -c android.intent.category.LAUNCHER 1" 2>/dev/null || {
        log_warn "No se pudo iniciar OsmAnd automáticamente. Ábrelo manualmente."
    }
    sleep 5
}

navigate_to() {
    local lat="$1"
    local lon="$2"
    local zoom="$3"
    log_info "Navegando a ($lat, $lon) zoom $zoom..."
    adb shell "am start -a android.intent.action.VIEW -d \"geo:$lat,$lon?z=$zoom\" net.osmand" 2>/dev/null || true
    sleep "$SCREENSHOT_DELAY"
}

take_screenshot() {
    local name="$1"
    local local_path="$OUTPUT_DIR/${name}.png"
    adb shell "screencap -p /sdcard/screenshot_tmp.png"
    adb pull "/sdcard/screenshot_tmp.png" "$local_path" 2>/dev/null
    adb shell "rm -f /sdcard/screenshot_tmp.png"
    if [ -f "$local_path" ]; then
        log_ok "Screenshot guardado: ${name}.png ($(du -h "$local_path" | cut -f1))"
        return 0
    else
        log_error "Falló la captura: $name"
        return 1
    fi
}

select_style() {
    log_info "Intentando seleccionar el estilo CleanOsmand..."
    adb shell "am broadcast -a net.osmand.style.selected --es style CleanOsmand" 2>/dev/null || true
    sleep 2
}

main() {
    echo "========================================"
    echo "  CleanOsmand - Generador de Snapshots"
    echo "  $(date)"
    echo "========================================"
    echo ""

    check_adb
    check_dependencies
    read_config

    mkdir -p "$OUTPUT_DIR"
    log_info "Directorio de salida: $OUTPUT_DIR"

    deploy_style
    check_map
    restart_osmand

    log_info "Esperando a que OsmAnd cargue completamente..."
    sleep 8

    select_style

    local i=0
    local success=0
    local failed=0

    while [ $i -lt $LOCATIONS_COUNT ]; do
        local loc_id="$(jq -r ".locations[$i].id" "$CONFIG_FILE")"
        local loc_name="$(jq -r ".locations[$i].name" "$CONFIG_FILE")"
        local lat="$(jq -r ".locations[$i].lat" "$CONFIG_FILE")"
        local lon="$(jq -r ".locations[$i].lon" "$CONFIG_FILE")"
        local zoom="$(jq -r ".locations[$i].zoom" "$CONFIG_FILE")"

        echo ""
        log_info "[$((i+1))/$LOCATIONS_COUNT] $loc_name ($loc_id)"

        navigate_to "$lat" "$lon" "$zoom"

        if take_screenshot "$loc_id"; then
            ((success++))
        else
            ((failed++))
        fi

        ((i++))
    done

    echo ""
    echo "========================================"
    log_info "Resumen: $success éxitos, $failed fallos"
    echo "========================================"

    if [ $success -gt 0 ]; then
        log_info "Snapshots guardados en: $OUTPUT_DIR"
        "$SCRIPT_DIR/generate-gallery.sh" "$OUTPUT_DIR" "$TIMESTAMP" || true
    fi
}

main "$@"
