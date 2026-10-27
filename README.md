# CleanOsmand

Estilo de renderizado minimalista y limpio para OsmAnd. Es autónomo (no depende de ningún otro estilo) y deriva de LightRS de xmd5a.

## Características

- Fondo blanco en modo día y oscuro en modo noche (#101418).
- Calles en escala de grises: a mayor importancia de la vía, color más oscuro.
- Anchos de trazo progresivos según nivel de vía y zoom.
- Vías sin asfaltar en trazo discontinuo color tostado (#b39d72).
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

1. Descarga `CleanOsmand.render.xml`.
2. Cópialo en la carpeta de estilos de OsmAnd:
   - OsmAnd gratuito: `Android/data/net.osmand/files/rendering/`
   - OsmAnd+: `Android/data/net.osmand.plus/files/rendering/`
   - Nightly: `Android/data/net.osmand.dev/files/rendering/`
3. Si tenías una versión anterior (por ejemplo WazeDrive.render.xml), bórrala de esa carpeta para evitar estilos duplicados.
4. Cierra OsmAnd por completo (desde las apps recientes) y vuelve a abrirlo: los estilos se leen al arrancar.
5. En Configurar mapa, elige CleanOsmand como estilo de mapa.

Importante: mantén desactivada la opción "Hide polygons (exc. buildings)" / "Ocultar polígonos (exc. edificios)" en los ajustes del estilo; si se activa, parques, agua y usos de suelo se vuelven transparentes.

## Verificar la versión instalada

Abre el archivo y comprueba que aparecen una vez cada uno:

- `attrColorValue="#ababab"` (color de autovía en modo día)
- `attrColorValue="#a1e09a"` (color de parque en modo día)

Si no aparecen, tienes una versión anterior y OsmAnd está renderizando el estilo viejo cacheado.

## Créditos y licencia

Derivado de LightRS de xmd5a (https://forum.openstreetmap.org/viewtopic.php?id=23125) y del estilo por defecto de OsmAnd. Licencia GPLv3, la misma que el trabajo original. Consulta el archivo LICENSE.
