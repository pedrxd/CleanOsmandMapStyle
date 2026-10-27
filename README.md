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

## Instalación

### Opción A: Plugin .osf (recomendado)

Descarga la última release desde [Releases](https://github.com/pedrxd/CleanOsmandMapStyle/releases):

1. Descarga `CleanOsmand-vx.y.z.osf`
2. Ábrelo con OsmAnd (o impórtalo desde Menú → Ajustes → Importar/Exportar → Importar desde archivo)
3. OsmAnd instalará automáticamente el estilo y los recursos (iconos de flechas personalizados)
4. En Configurar mapa, elige CleanOsmand como estilo de mapa

Importante: mantén desactivada la opción "Hide polygons (exc. buildings)" / "Ocultar polígonos (exc. edificios)" en los ajustes del estilo; si se activa, parques, agua y usos de suelo se vuelven transparentes.

## Créditos y licencia

Derivado de LightRS de xmd5a y del estilo por defecto de OsmAnd. Licencia GPLv3, la misma que el trabajo original. Consulta el archivo LICENSE.
