#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

OUTPUT_DIR="${1:-$REPO_ROOT/previews/latest}"
TIMESTAMP="${2:-$(date +%Y%m%d-%H%M%S)}"
GALLERY_FILE="$OUTPUT_DIR/gallery.html"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $1"; }

if [ ! -d "$OUTPUT_DIR" ]; then
    log_info "Directorio no existe: $OUTPUT_DIR"
    exit 1
fi

PNGS=$(ls "$OUTPUT_DIR"/*.png 2>/dev/null | sort || true)
if [ -z "$PNGS" ]; then
    log_info "No hay imágenes PNG en $OUTPUT_DIR"
    exit 1
fi

cat > "$GALLERY_FILE" << 'GALLERY_EOF'
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>CleanOsmand - Galería de Snapshots</title>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background: #f5f5f5;
    padding: 20px;
}
h1 {
    text-align: center;
    margin-bottom: 10px;
    color: #333;
}
.subtitle {
    text-align: center;
    color: #666;
    margin-bottom: 30px;
    font-size: 14px;
}
.gallery {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(360px, 1fr));
    gap: 20px;
    max-width: 1600px;
    margin: 0 auto;
}
.card {
    background: white;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    transition: transform 0.2s, box-shadow 0.2s;
}
.card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 24px rgba(0,0,0,0.15);
}
.card img {
    width: 100%;
    height: auto;
    display: block;
    cursor: pointer;
}
.card .label {
    padding: 12px 16px;
    font-size: 14px;
    font-weight: 600;
    color: #333;
    border-top: 1px solid #eee;
}
.card .meta {
    padding: 0 16px 12px;
    font-size: 12px;
    color: #888;
}
.modal {
    display: none;
    position: fixed;
    z-index: 1000;
    left: 0; top: 0;
    width: 100%; height: 100%;
    background: rgba(0,0,0,0.9);
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
    background: rgba(255,255,255,0.2);
    color: white;
    border: none;
    font-size: 32px;
    padding: 20px 15px;
    cursor: pointer;
    border-radius: 4px;
}
.nav-btn:hover { background: rgba(255,255,255,0.4); }
.nav-prev { left: 20px; }
.nav-next { right: 20px; }
</style>
</head>
<body>
<h1>CleanOsmand - Galería de Snapshots</h1>
<p class="subtitle">TIMESTAMP_PLACEHOLDER</p>
<div class="gallery">
GALLERY_EOF

for png in $PNGS; do
    filename=$(basename "$png")
    name="${filename%.png}"
    display_name=$(echo "$name" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')
    cat >> "$GALLERY_FILE" << CARD_EOF
<div class="card" onclick="openModal('$filename')">
    <img src="$filename" alt="$display_name" loading="lazy">
    <div class="label">$display_name</div>
</div>
CARD_EOF
done

cat >> "$GALLERY_FILE" << 'GALLERY_EOF'
</div>

<div id="modal" class="modal" onclick="closeModal()">
    <button class="nav-btn nav-prev" onclick="event.stopPropagation(); prevImage()">&#10094;</button>
    <img id="modal-img" src="" alt="">
    <button class="nav-btn nav-next" onclick="event.stopPropagation(); nextImage()">&#10095;</button>
</div>

<script>
const images = Array.from(document.querySelectorAll('.card img')).map(img => img.src);
let currentIdx = 0;
const modal = document.getElementById('modal');
const modalImg = document.getElementById('modal-img');

function openModal(src) {
    currentIdx = images.indexOf(src);
    modalImg.src = src;
    modal.style.display = 'block';
    document.body.style.overflow = 'hidden';
}
function closeModal() {
    modal.style.display = 'none';
    document.body.style.overflow = '';
}
function prevImage() {
    currentIdx = (currentIdx - 1 + images.length) % images.length;
    modalImg.src = images[currentIdx];
}
function nextImage() {
    currentIdx = (currentIdx + 1) % images.length;
    modalImg.src = images[currentIdx];
}
document.addEventListener('keydown', e => {
    if (modal.style.display === 'block') {
        if (e.key === 'Escape') closeModal();
        if (e.key === 'ArrowLeft') prevImage();
        if (e.key === 'ArrowRight') nextImage();
    }
});
</script>
</body>
</html>
GALLERY_EOF

sed -i.bak "s|TIMESTAMP_PLACEHOLDER|Generado: $TIMESTAMP|" "$GALLERY_FILE" && rm -f "$GALLERY_FILE.bak"

log_ok "Galería HTML generada: $GALLERY_FILE"
log_info "Ábrela con: open $GALLERY_FILE (Mac) o xdg-open $GALLERY_FILE (Linux)"
