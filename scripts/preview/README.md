# Preview de estilo CleanOsmand

Herramientas para generar snapshots del estilo directamente desde un dispositivo Android conectado por USB, sin necesidad de cargar manualmente cada cambio en el móvil.

## Requisitos

- **adb** (Android Debug Bridge) instalado
- Un **dispositivo Android** con OsmAnd instalado y depuración USB activada
- **jq** y **python3** instalados
- Un **mapa .obf** descargado en el dispositivo (ej: España, Andorra, o cualquier región)

### Instalar dependencias

```bash
# Linux (Debian/Ubuntu)
sudo apt install adb jq python3

# macOS
brew install android-platform-tools jq python3
```

### Configurar el móvil

1. Activa **Opciones de desarrollador** (Ajustes → Acerca del teléfono → pulsa 7 veces "Número de compilación")
2. Activa **Depuración USB** (Opciones de desarrollador → Depuración USB)
3. Conecta el móvil por USB y acepta el diálogo de depuración
4. Verifica: `adb devices` (debe mostrar tu dispositivo)

## Uso

### 1. Preparar el mapa de prueba (una sola vez)

```bash
./scripts/preview/setup-test-map.sh
```

Descarga un mapa pequeño desde OsmAnd (recomendado: **Andorra**, ~2MB) o cualquier región de España.

### 2. Generar snapshots de todas las ubicaciones

```bash
./scripts/preview/generate-snapshots.sh
```

Esto:
1. Copia el `CleanOsmand.render.xml` actual al móvil
2. Reinicia OsmAnd
3. Navega por las 10 ubicaciones configuradas
4. Toma una captura de pantalla en cada una
5. Genera una galería HTML automáticamente

Las imágenes se guardan en `previews/YYYYMMDD-HHMMSS/` y la galería en `previews/YYYYMMDD-HHMMSS/gallery.html`.

### 3. Comparar dos ejecuciones (A/B testing)

Después de hacer cambios en el estilo y volver a generar snapshots:

```bash
./scripts/preview/compare-previews.sh 20240115-143022 20240116-091530
```

Genera una página HTML con comparación lado a lado de cada ubicación. Útil para ver exactamente qué cambió.

## Configurar ubicaciones de prueba

Edita `scripts/preview/test-locations.json` para añadir, quitar o modificar las ubicaciones de prueba:

```json
{
  "locations": [
    {
      "id": "mi-ciudad",
      "name": "Mi Ciudad",
      "lat": 40.4168,
      "lon": -3.7038,
      "zoom": 15,
      "description": "Descripción opcional"
    }
  ],
  "settings": {
    "packageName": "net.osmand",
    "obfFile": "Spain_europe.obf"
  }
}
```

### Ubicaciones por defecto incluidas

| ID | Nombre | Coordenadas | Zoom | Qué prueba |
|----|--------|-------------|------|------------|
| madrid-centro | Madrid Centro | 40.4168, -3.7038 | 15 | Calles densas, centro histórico |
| barcelona-eixample | Barcelona Eixample | 41.3874, 2.1686 | 15 | Grid urbano denso |
| valencia-ciudad | Valencia Ciudad | 39.4699, -0.3763 | 15 | Zona peatonal, turismo |
| sevilla-centro | Sevilla Centro | 37.3891, -5.9845 | 15 | Calles estrechas, casco antiguo |
| zaragoza-rio | Zaragoza Ebro | 41.6561, -0.8773 | 14 | Río, parques, zonas verdes |
| bilbao-ensanche | Bilbao Ensanche | 43.2627, -2.9253 | 15 | Avenidas anchas, ensanche |
| granada-albaicin | Granada Albaicín | 37.1773, -3.5986 | 16 | Calles empinadas, estrechas |
| madrid-retiro | Madrid Retiro | 40.4153, -3.6844 | 15 | Parque, zona verde urbana |
| malaga-puerto | Málaga Puerto | 36.7213, -4.4214 | 15 | Zona marítima, puerto |
| alicante-casco | Alicante Casco Antiguo | 38.3452, -0.4810 | 16 | Casco antiguo, junto al castillo |

## Flujo de trabajo recomendado

```bash
# 1. Editas el estilo
vim src/rendering/CleanOsmand.render.xml

# 2. Generas snapshots (móvil conectado por USB)
./scripts/preview/generate-snapshots.sh
# → Abre previews/XXXX/gallery.html para ver el resultado

# 3. Si quieres comparar con la versión anterior
./scripts/preview/compare-previews.sh <run-anterior> <run-actual>

# 4. Iteras hasta encontrar la configuración perfecta
#    (vuelve al paso 1)

# 5. Cuando estés satisfecho, genera el .osf
./scripts/build-osf.sh dev
```

## Notas

- Si OsmAnd no se inicia automáticamente, ábrelo manualmente en el móvil
- El estilo se despliega en `/sdcard/Android/data/net.osmand/files/rendering/`
- Si usas OsmAnd+ (de pago), cambia `packageName` a `net.osmand.plus` en `test-locations.json`
- Las capturas se toman con `screencap` nativo de Android (sin root necesario)
- La galería HTML permite hacer zoom clicando en cada imagen
