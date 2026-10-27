#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PREVIEWS_DIR="$REPO_ROOT/previews"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

usage() {
    echo "Uso: $0 <run-1> <run-2> [salida]"
    echo ""
    echo "Compara dos ejecuciones de snapshots lado a lado."
    echo ""
    echo "Argumentos:"
    echo "  run-1    Timestamp o nombre de la primera carpeta (ej: 20240115-143022)"
    echo "  run-2    Timestamp o nombre de la segunda carpeta"
    echo "  salida   (opcional) Nombre de la carpeta de salida"
    echo ""
    echo "Ejemplo:"
    echo "  $0 20240115-143022 20240116-091530"
    echo "  $0 antes-cambio despues-cambio comparacion"
    echo ""
    echo "Carpetas disponibles en $PREVIEWS_DIR:"
    ls -1 "$PREVIEWS_DIR" 2>/dev/null | grep -v '\.html' || echo "  (ninguna)"
    exit 1
}

if [ $# -lt 2 ]; then
    usage
fi

RUN1="$1"
RUN2="$2"
OUTPUT_NAME="${3:-compare-$RUN1-vs-$RUN2}"
OUTPUT_DIR="$PREVIEWS_DIR/$OUTPUT_NAME"

DIR1="$PREVIEWS_DIR/$RUN1"
DIR2="$PREVIEWS_DIR/$RUN2"

if [ ! -d "$DIR1" ]; then
    log_error "No existe: $DIR1"
    usage
fi
if [ ! -d "$DIR2" ]; then
    log_error "No existe: $DIR2"
    usage
fi

mkdir -p "$OUTPUT_DIR"

log_info "Comparando:"
log_info "  Run 1 (A - Izquierda): $RUN1"
log_info "  Run 2 (B - Derecha):   $RUN2"
log_info "  Salida: $OUTPUT_DIR"

COMPARISON_FILE="$OUTPUT_DIR/comparison.html"

cat > "$COMPARISON_FILE" << 'COMPARE_EOF'
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>CleanOsmand - Comparación A/B</title>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background: #1a1a2e;
    color: #eee;
    padding: 20px;
}
h1 { text-align: center; margin-bottom: 5px; font-size: 20px; }
.subtitle { text-align: center; color: #888; margin-bottom: 20px; font-size: 13px; }
.legend {
    display: flex;
    justify-content: center;
    gap: 30px;
    margin-bottom: 20px;
}
.legend-item {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 14px;
}
.legend-color {
    width: 20px; height: 20px;
    border-radius: 4px;
    border: 2px solid #555;
}
.legend-a { background: #2196F3; }
.legend-b { background: #FF9800; }

.comparison-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(700px, 1fr));
    gap: 20px;
    max-width: 1800px;
    margin: 0 auto;
}
.compare-card {
    background: #16213e;
    border-radius: 8px;
    overflow: hidden;
    border: 1px solid #0f3460;
}
.compare-card .title {
    padding: 10px 15px;
    font-size: 14px;
    font-weight: 600;
    background: #0f3460;
    text-transform: capitalize;
}
.compare-images {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 2px;
}
.compare-images .img-wrapper {
    position: relative;
}
.compare-images .img-wrapper::before {
    content: attr(data-label);
    position: absolute;
    top: 8px; left: 8px;
    background: rgba(0,0,0,0.7);
    color: white;
    padding: 4px 10px;
    border-radius: 4px;
    font-size: 12px;
    font-weight: 600;
    z-index: 10;
}
.compare-images img {
    width: 100%;
    height: auto;
    display: block;
    cursor: pointer;
}
.compare-images .img-a::before { background: rgba(33,150,243,0.9); }
.compare-images .img-b::before { background: rgba(255,152,0,0.9); }

.modal {
    display: none;
    position: fixed;
    z-index: 1000;
    left: 0; top: 0;
    width: 100%; height: 100%;
    background: rgba(0,0,0,0.95);
    cursor: zoom-out;
}
.modal img {
    margin: auto;
    display: block;
    max-width: 95%;
    max-height: 95%;
    position: absolute;
    top: 50%; left: 50%;
    transform: translate(-50%, -50%);
}
.nav-btn {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    background: rgba(255,255,255,0.15);
    color: white;
    border: none;
    font-size: 32px;
    padding: 20px 15px;
    cursor: pointer;
    border-radius: 4px;
}
.nav-btn:hover { background: rgba(255,255,255,0.3); }
.nav-prev { left: 20px; }
.nav-next { right: 20px; }
</style>
</head>
<body>
<h1>CleanOsmand — Comparación A/B</h1>
<p class="subtitle">A (azul) = RUN1_PLACEHOLDER &nbsp;|&nbsp; B (naranja) = RUN2_PLACEHOLDER</p>
<div class="legend">
    <div class="legend-item"><div class="legend-color legend-a"></div> <span>Run A: RUN1_PLACEHOLDER</span></div>
    <div class="legend-item"><div class="legend-color legend-b"></div> <span>Run B: RUN2_PLACEHOLDER</span></div>
</div>
<div class="comparison-grid">
COMPARE_EOF

COMMON_PNGS=""
for png in "$DIR1"/*.png; do
    [ -f "$png" ] || continue
    filename=$(basename "$png")
    if [ -f "$DIR2/$filename" ]; then
        COMMON_PNGS="$COMMON_PNGS $filename"
    fi
done

if [ -z "$COMMON_PNGS" ]; then
    log_warn "No hay imágenes comunes entre las dos ejecuciones."
fi

IMAGE_LIST=""
for filename in $COMMON_PNGS; do
    name="${filename%.png}"
    display_name=$(echo "$name" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')
    cp "$DIR1/$filename" "$OUTPUT_DIR/a-$filename"
    cp "$DIR2/$filename" "$OUTPUT_DIR/b-$filename"
    IMAGE_LIST="$IMAGE_LIST $filename"
    cat >> "$COMPARISON_FILE" << CARD_EOF
<div class="compare-card">
    <div class="title">$display_name</div>
    <div class="compare-images">
        <div class="img-wrapper img-a" data-label="A">
            <img src="a-$filename" alt="A: $display_name" onclick="openModal('a-$filename')" loading="lazy">
        </div>
        <div class="img-wrapper img-b" data-label="B">
            <img src="b-$filename" alt="B: $display_name" onclick="openModal('b-$filename')" loading="lazy">
        </div>
    </div>
</div>
CARD_EOF
done

cat >> "$COMPARISON_FILE" << 'COMPARE_EOF'
</div>

<div id="modal" class="modal" onclick="closeModal()">
    <button class="nav-btn nav-prev" onclick="event.stopPropagation(); prevImage()">&#10094;</button>
    <img id="modal-img" src="" alt="">
    <button class="nav-btn nav-next" onclick="event.stopPropagation(); nextImage()">&#10095;</button>
</div>

<script>
const modalImages = [
COMPARE_EOF

FIRST=true
for filename in $COMMON_PNGS; do
    name="${filename%.png}"
    if $FIRST; then
        FIRST=false
    else
        echo "," >> "$COMPARISON_FILE"
    fi
    printf "    { a: 'a-%s', b: 'b-%s', name: '%s' }" "$filename" "$filename" "$name" >> "$COMPARISON_FILE"
done

cat >> "$COMPARISON_FILE" << 'JS_EOF'
];
let currentIdx = 0;
const modal = document.getElementById('modal');
const modalImg = document.getElementById('modal-img');

function openModal(src) {
    const base = src.replace(/^[ab]-/, '');
    currentIdx = modalImages.findIndex(m => m.a.endsWith(base) || m.b.endsWith(base));
    if (currentIdx < 0) currentIdx = 0;
    modalImg.src = src;
    modal.style.display = 'block';
    document.body.style.overflow = 'hidden';
}
function closeModal() {
    modal.style.display = 'none';
    document.body.style.overflow = '';
}
function showImage(side) {
    const item = modalImages[currentIdx];
    modalImg.src = side === 'a' ? item.a : item.b;
}
function prevImage() {
    currentIdx = (currentIdx - 1 + modalImages.length) % modalImages.length;
    showImage('a');
}
function nextImage() {
    currentIdx = (currentIdx + 1) % modalImages.length;
    showImage('a');
}
document.addEventListener('keydown', e => {
    if (modal.style.display === 'block') {
        if (e.key === 'Escape') closeModal();
        if (e.key === 'ArrowLeft') { prevImage(); }
        if (e.key === 'ArrowRight') { nextImage(); }
        if (e.key === 'a' || e.key === 'A') { showImage('a'); }
        if (e.key === 'b' || e.key === 'B') { showImage('b'); }
    }
});
</script>
</body>
</html>
JS_EOF

sed -i.bak \
    -e "s|RUN1_PLACEHOLDER|$RUN1|g" \
    -e "s|RUN2_PLACEHOLDER|$RUN2|g" \
    "$COMPARISON_FILE" && rm -f "$COMPARISON_FILE.bak"

log_ok "Comparación generada: $COMPARISON_FILE"
log_info "Ábrela con: open $COMPARISON_FILE (Mac) o xdg-open $COMPARISON_FILE (Linux)"
log_info ""
log_info "Atajos de teclado en el visor: ← → navegar, A/B cambiar lado, Esc cerrar"
