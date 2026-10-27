# CleanOsmand

Estilo de renderizado minimalista y limpio para OsmAnd. Es aut\u00f3nomo (no depende de ning\u00fan otro estilo) y deriva de LightRS de xmd5a.

## Caracter\u00edsticas

- Fondo blanco en modo d\u00eda y oscuro en modo noche (#101418).
- Calles en escala de grises: a mayor importancia de la v\u00eda, color m\u00e1s oscuro.
- Anchos de trazo progresivos seg\u00fan nivel de v\u00eda y zoom.
- V\u00edas sin asfaltar en trazo discontinuo color tostado (#b39d72).
- Flechas de sentido \u00fanico en blanco con borde gris para mejor visibilidad.
- Nombres de calle escalonados: las v\u00edas importantes muestran nombre antes.
- Edificios completamente ocultos (sin relleno ni contorno).
- POIs m\u00ednimos y sin v\u00edas no motorizadas (aceras, ciclov\u00edas, senderos, escaleras, pasos de peatones).
- Verde pastel unificado (#a1e09a) para parques, jardines, bosques, prados, zonas verdes y huertos.
- Agua en azul claro (#c9e6f5).
- Ruta de navegaci\u00f3n en azul transl\u00facido con borde amarillo.

## Instalaci\u00f3n

### Opci\u00f3n A: Plugin .osf (recomendado)

Descarga la \u00faltima release desde [Releases](https://github.com/pedrxd/CleanOsmandMapStyle/releases):

1. Descarga `CleanOsmand-vx.y.z.osf`
2. \u00c1brelo con OsmAnd (o imp\u00f3rtalo desde Men\u00fa \u2192 Ajustes \u2192 Importar/Exportar \u2192 Importar desde archivo)
3. OsmAnd instalar\u00e1 autom\u00e1ticamente el estilo y los recursos (iconos de flechas personalizados)
4. En Configurar mapa, elige CleanOsmand como estilo de mapa

Importante: mant\u00e9n desactivada la opci\u00f3n "Hide polygons (exc. buildings)" / "Ocultar pol\u00edgonos (exc. edificios)" en los ajustes del estilo; si se activa, parques, agua y usos de suelo se vuelven transparentes.

## Cr\u00e9ditos y licencia

Derivado de LightRS de xmd5a y del estilo por defecto de OsmAnd. Licencia GPLv3, la misma que el trabajo original. Consulta el archivo LICENSE.
