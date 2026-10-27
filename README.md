# CleanOsmand

Estilo de renderizado minimalista y limpio para OsmAnd. Es autónomo (no depende de ningún otro estilo) y deriva de LightRS de xmd5a.

## Características

- Fondo blanco en modo día y oscuro en modo noche (#101418).
- Calles en escala de grises: a mayor importancia de la vía, color más oscuro.
- Anchos de trazo progresivos según nivel de vía y zoom.
- Vías sin asfaltar en trazo discontinuo color tostado (#b39d72).
- Flechas de sentido único en blanco con borde gris para mejor visibilidad.
- Nombres de calle escalonados: las vías importantes muestran nombre antes.
- POIs mínimos y sin vías no motorizadas (aceras, ciclovías, senderos, escaleras, pasos de peatones).
- Parques en verde pastel (#a1e09a) y agua en azul claro (#c9e6f5).
- Ruta de navegación en azul translúcido con borde amarillo.

## Colores principales (modo día)

| Elemento | Color |
| --- | --- |
| Autovía | #ababab |
| Troncal | #b4b4b4 |
| Primaria | #bdbdbd |
| Secundaria | #c6c6c6 |
| Terciaria | #cfcfcf |
| Residencial | #d8d8d8 |
| Servicio | #e1e1e1 |
| Sin asfaltar / pista | #b39d72 |
| Parque | #a1e09a |
| Agua | #c9e6f5 |

## Instalación

### Opción A: Plugin .osf (recomendado)

Descarga la última release desde [Releases](https://github.com/pedrxd/CleanOsmandMapStyle/releases):

1. Descarga `CleanOsmand-Vx.y.z.osf`
2. Ábrelo con OsmAnd (o impórtalo desde Menú → Ajustes → Importar/Exportar → Importar desde archivo)
3. OsmAnd instalará automáticamente el estilo y los recursos (iconos de flechas personalizados)
4. En Configurar mapa, elige CleanOsmand como estilo de mapa

### Opción B: Solo el archivo XML (instalación manual)

1. Descarga `src/rendering/CleanOsmand.render.xml`
2. Cópialo en la carpeta de estilos de OsmAnd:
   - OsmAnd gratuito: `Android/data/net.osmand/files/rendering/`
   - OsmAnd+: `Android/data/net.osmand.plus/files/rendering/`
   - Nightly: `Android/data/net.osmand.dev/files/rendering/`
3. Copia los 4 iconos PNG de `src/res/` en la carpeta `rendering/` junto al XML:
   - `oneway_white_gray.png`
   - `oneway_white_gray_big.png`
   - `oneway_reverse_white_gray.png`
   - `oneway_reverse_white_gray_big.png`
4. Si tenías una versión anterior (por ejemplo WazeDrive.render.xml), bórrala de esa carpeta para evitar estilos duplicados
5. Cierra OsmAnd por completo (desde las apps recientes) y vuelve a abrirlo: los estilos se leen al arrancar
6. En Configurar mapa, elige CleanOsmand como estilo de mapa

## Estructura del repositorio

```
src/                          ← Fuente única (todo el contenido del plugin)
├── items.json                ← Configuración del plugin .osf
├── rendering/
│   └── CleanOsmand.render.xml ← Estilo de mapa
└── res/                      ← Recursos (iconos PNG)
    ├── cleanosmand-icon.png
    ├── oneway_white_gray.png
    ├── oneway_white_gray_big.png
    ├── oneway_reverse_white_gray.png
    └── oneway_reverse_white_gray_big.png

scripts/
└── build-osf.sh              ← Script para generar el paquete .osf

.github/workflows/
├── build-osf.yml             ← CI: genera OSF de prueba (PRs) y beta (main)
└── release.yml               ← CI: genera release en ramas release/Vx.y
```

## Flujo de trabajo (GitFlow)

```
main (trunk)
  │  ← cada push genera OSF beta automáticamente (Actions)
  │
  ├──► feature/xxx ──► PR ──► main     (cada PR genera OSF de prueba)
  │
  └──► release/V1.0 ──► push ──► GitHub Release con OSF
         release/V1.1 ──► push ──► GitHub Release con OSF
         release/V2.0 ──► push ──► GitHub Release con OSF
```

### Tipos de builds

| Rama / Evento | Versión generada | Dónde descargar |
| --- | --- | --- |
| `main` (push) | `beta-abc1234` | Actions artifacts |
| PR (pull_request) | `pr-3-abc1234` | Comentario del PR + Actions |
| `release/V1.0` (push) | `1.0` | [GitHub Releases](https://github.com/pedrxd/CleanOsmandMapStyle/releases) |

### Cómo crear una release

1. Crea una rama desde `main`: `git checkout -b release/V1.0`
2. Haz los ajustes finales (versionado, changelog)
3. Push: `git push -u origin release/V1.0`
4. La CI genera automáticamente la release en GitHub con el `.osf`

### Desarrollo local

```bash
# Generar OSF de prueba
./scripts/build-osf.sh dev

# Generar OSF con versión específica
./scripts/build-osf.sh 1.0.0
```

Importante: mantén desactivada la opción "Hide polygons (exc. buildings)" / "Ocultar polígonos (exc. edificios)" en los ajustes del estilo; si se activa, parques, agua y usos de suelo se vuelven transparentes.

## Créditos y licencia

Derivado de LightRS de xmd5a (https://forum.openstreetmap.org/viewtopic.php?id=23125) y del estilo por defecto de OsmAnd. Licencia GPLv3, la misma que el trabajo original. Consulta el archivo LICENSE.
