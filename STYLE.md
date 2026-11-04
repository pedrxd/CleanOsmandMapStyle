# STYLE.md — Guía esquemática del estilo CleanOsmand

Fuente de verdad del renderizado: `src/rendering/CleanOsmand.render.xml` (estilo autónomo, `depends=""`, `version="1"`).

**Regla de uso:** antes de tocar el XML del estilo, lee este documento para saber qué se pinta ahora y dónde. Después de cualquier cambio en el XML, actualiza este documento en el mismo commit/PR. La estructura del XML es, en orden: `renderingProperty` → `renderingAttribute`/`renderingConstant` → `<order>` → `<text>` → `<point>` → `<polygon>` → `<line>`.

## 1. Filosofía del estilo

- Minimalista: fondo blanco de día / oscuro de noche, carreteras en escala de grises (más importante = más oscuro), sin iconos de POI.
- Verde solo en parques y reservas naturales. Agua siempre por encima de todos los polígonos.
- Edificios, piscinas, bosques, matorrales, huertos y demás vegetación "no esencial" no se pintan.
- Sin vallas/muros (`barrier=fence/wall/...` no se dibujan) y sin flechas de sentido custom en las vías.
- Probar cambios: `./scripts/build-osf.sh dev` genera un `.osf` de prueba.

## 2. Fondo y modos

| Caso | Color |
| --- | --- |
| Día (`defaultColor`) | `#ffffff` |
| Noche (`nightMode="true"`) | `#101418` |
| `noPolygons=true` | `#00ffffff` (transparente; ver aviso en README: mantener desactivado) |

Todas las constantes de color tienen variante día/noche (`...Day` / `...Night` o `case nightMode="true"`).

## 3. Propiedades de usuario (`renderingProperty`)

| Propiedad | Efecto |
| --- | --- |
| `moreDetailed` | Polígonos mínimos visibles: 10 (vs 40); anchos extra en residential/service/pedestrian/footway/cycleway/path z12-14; nombre de tertiary desde z14 |
| `noPolygons` | Fondo transparente; sombra en líneas no motorizadas |
| `hideBuildings` | Oculta edificios (ya son transparentes por defecto, ver §6) |
| `hideNonVehicleHighways` | Oculta pedestrian/footway/cycleway/path/steps (bloque `hideNonVehicleHighways="false"`) |
| `hideAccess` | Muestra overlay `access=no/private` en unclassified/residential/service |
| `hideText` | Oculta todas las etiquetas (salvo leyenda y waypoints) |
| `hideHouseNumbers` | Definida pero sin regla de texto asociada: los números de casa no se pintan |
| `hideUnderground` | `layer=-1`, `indoor=yes`, `covered=yes` pasan a `order=-1` (ocultos) |
| `currentTrackColor` / `currentTrackWidth` | Color (16 valores) y ancho (thin/medium/bold) del GPX en grabación |
| `appMode` / `baseAppMode` | Modo de perfil; afecta órdenes de dibujo (p. ej. `baseAppMode=car` eleva ferrocarril ybaja admin boundaries a order 34) |
| `transportStops` | Definida pero sin uso (se eliminaron las etiquetas de paradas, PR #11) |
| `eleUnits` | Unidades de elevación (`ele`/`ele_feet`) en etiquetas de picos/volcanes |

## 4. Atributos globales (`renderingAttribute`)

- **Ruta de navegación (`route`)**: día `#cc2b5fd6` ancho `12:8` con borde `color_3=#ffd54b` ancho `5:7`; noche `#cc3a66c4`.
- **GPX actual (`gpx`)**: 16 colores (`red`…`translucent_purple`); anchos thin/medium/bold con `strokeWidth` progresivo desde z3 y `pathEffect` en `routePoints=true`.
- **Densidad**: `roadDensityZoomTile` = 4 desde z15 (3 antes); `polygonMinSizeToDisplay` = 10 con `moreDetailed` (40 sin él); `roadsDensityLimitPerTile` = 100.
- **Sombra (`shadowRendering`)**: z14+ sombra sólida (nivel 3) `#969696` día / `#464646` noche; z9-13 `#969696` solo día; < z9 sin sombra. Hace destacar los puentes.
- **Regla/medición**: `rulerCircle`, `rulerCircleAlt`, `rulerLine` (negro punteado, noche `#aaaaaa`), `rulerLineFont`, `measureDistanceLine` `#536dfe` punteado (noche `#ff8800`), `markerGuideline`, `markerPlanRouteline`.
- Otros: `defaultSymbolPathSpacing=5`, `defaultBlockPathSpacing=100`, `globalPathPadding=0`, `barrierMinZoom=17`, `roadMinZoom=14`, `debugTextDisplayBBox=false`.

## 5. Orden de pintado (`<order>`)

Menor `order` = más abajo. Lo esencial:

- **Puntos (POI)**: `order=128` (encima de todo). Solo tags genéricos (amenity, shop, tourism, natural, railway, place, barrier, aeroway…); sin iconos (ver §8).
- **Polígonos**: `landuse=residential`/`construction` order 4; parques/reservas (`leisure=park`, `leisure=nature_reserve`, `boundary=national_park`, `boundary=protected_area`) order 6; `military`/`danger_area` order 8; `man_made=bridge` 10; `public_transport=platform` 12; **agua (coastline, natural=water/bay, landuse=reservoir/water/basin, waterway=riverbank/canal/dock) order 90 → siempre por encima de todos los polígonos, mar incluido sobre parques**; `building` order -1 (abajo, y transparente).
- **Líneas**: agua (`waterway`) order 9 (debajo de carreteras; `layer=1` → 68); vallas `barrier` order 20; boundaries/admin order 62 (34 en modos car/bicycle/pedestrian); carreteras order 35-84 según clase, con offsets por `layer` (layer=1 suma ~+23, layer=-1 baja a ~20-62, layer=-2 ~19-41); `highway=track` 64; coastline rota/ferry 63; ferrocarril 58 (`layer=1` 88; en modo car 36/71); `aerialway` y `power=line` 96 (sobre edificios); línea por defecto 12.

## 6. Polígonos (`<polygon>`), por zoom

| Elemento | minzoom | Color día / noche |
| --- | --- | --- |
| `building=*` | 16 | `#00ffffff` transparente (relleno y borde) → **edificios ocultos siempre** |
| `tourism=attraction` (z13), `amenity=place_of_worship` (z15), `amenity/historic=monastery` (z13) | 13-15 | `#f7edd2` / `#685d20` |
| `landuse=cemetery`, `amenity=grave_yard` | 12 | verde pastel `#a1e09a` / `#23301f` |
| `natural=beach` | 11 | shader `beach2` / `beach2night` |
| Parques y reservas: `leisure=park`, `leisure=nature_reserve`, `boundary=national_park`, `boundary=protected_area` | 8 | verde progresivo por bandas (tabla abajo) |
| `landuse=military` | 10 | rojo translúcido `#29ff0000` + borde `#c8ea6691` (noche `#44ff0000`/`#84ffa0c0`) |
| `military=danger_area` | 7 | igual que military |
| `landuse=residential` | 10 | `#f4f4f4` / `#1a1a1a` |
| `landuse=industrial` | 9 | `#efeff2` / `#232327` |
| `amenity=parking` | 15 | `#ededed` / `#303030` |
| Agua: `natural=coastline` z1, `natural=water`/`bay` z4, `landuse=reservoir`/`water` z7, `landuse=basin` z10, `waterway=riverbank`/`canal`/`dock` z10 | 1-10 | `#c9e6f5` / `#1b2a3c`; `intermittent=yes` → shader `water_intermittent(_night)` |
| `place=island`/`islet`, `natural=land` | — | fondo: `#ffffff` / `#000000` |
| `aeroway=aerodrome` | 11 | `#256b79f1` + borde mismo color |
| `aeroway=runway` (polígono) | — | `#bbbbcc` / `#90909e` |
| `aeroway=apron` | 13 | `#e0c4fb` / `#4c3a5d` |
| `aeroway=terminal` | 14 | `#b371b7` + borde `#964ae5` (noche `#835286`/`#c98df7`) |
| `area:highway` primary/secondary/tertiary/unclassified | 15 | `#ffa352` / `#4E1100` |
| `area:highway=residential`, `man_made=bridge` (área) | 16 | `#7d7d7d` / `#4E1100` |
| `area:highway=service`, `highway=rest_area` | 16 | `#a4a4a4` / `#4f2215` |
| `area:highway=track` | 16 | `#6b6b6b` / `#2e2e2e` |
| Vías no motorizadas como área (`hideNonVehicleHighways=false`) | 16 | `#CACACA` / `#2E2E2E` |
| `public_transport=platform`, `railway=halt` | 16 | `#888888` |

**Verde de parques por zoom** (`parkColorDay/NightZ*`): z8-9 `#d8f2d2`/`#1c261c` → z10-11 `#c8e8c0`/`#212c21` → z12-13 `#b8deae`/`#263326` → z14-15 `#abe0a0`/`#283626` → z16+ `#a8e5a1`/`#2e3d2e`. Se intensifica al acercarse; los polígonos pequeños los filtra `polygonMinSizeToDisplay`.

**No se pintan** (eliminado en PR #18): `leisure=swimming_pool` (piscinas), `natural=wood`, `landuse=forest`, `natural=scrub`, humedales como polígono verde, huertos (`allotments`), viñedos, `garden`/`common`/`playground`/`pitch`/`grass`/`meadow`/`greenfield`, etc.

## 7. Líneas (`<line>`)

### 7.1 Colores de carretera por clase (día / noche / construction=yes)

| Clase | Día | Noche | Construction día/noche |
| --- | --- | --- | --- |
| motorway | `#9A9A9A` | `#BABABA` | `#B0B0B0` / `#646464` |
| trunk | `#A2A2A2` | `#AFAFAF` | `#B8B8B8` / `#656565` |
| primary | `#AAAAAA` | `#A2A2A2` | `#B8B8B8` / `#646464` |
| secondary | `#B2B2B2` | `#929292` | `#BDBDBD` / `#646464` |
| tertiary | `#BABABA` | `#828282` | `#C1C1C1` / `#656565` |
| **unclassified** | = tertiary (`#BABABA`/`#828282`), desde **z11** | | |
| residential / living_street | `#C2C2C2` | `#535353` | `#CDCDCD` / `#434343` |
| service | `#CACACA` (≤z14) | `#434343` (≤z14) | `#D4D4D4` / `#393939` |
| busway | `#C2C2C2` | `#535353` | `#CDCDCD` / `#535353` |
| road | `#C3C3C3` | `#3E3E3E` | — |
| track | `#B7A37E` | `#8D7B58` | — |
| non motorizadas (pedestrian/footway/cycleway/path/steps) | `#C1C1C1` | `#343434` | — |
| sin asfaltar (`surface=unpaved/compacted/gravel/fine_gravel/dirt/ground/grass/sand/mud/clay/pebblestone`) | `#A18D67` punteado `7_4` (cap BUTT) | `#7F6E4C` | — |
| Puentes (`bridge=yes`): casing `color_0` | `#8a8a8a`, cap SQUARE, sin sombra | `#4a4a4a` | — |

### 7.2 Anchos por zoom (`ancho:ancho`, cap ROUND salvo que se indique)

| Vía | z≤6 | z7-8 | z9 | z10 | z11 | z12 | z13 | z14 | z15 | z16 | z17 | z18 | z19+ |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| motorway/trunk z6-15 | 1 | 1.5 | 1.6 | 1.8 | 2 | 2.5 | 2.7 | 3.6 | 5 | — | — | — | — |
| primary z6-15 / secondary z9-15 | 0.5 | 1 | 1.6 | 1.8 | 2 | 2.5 | 2.7 | 3.6 | 5 | — | — | — | — |
| motorway…secondary z16+ | — | | | | | | | | | 7.5 | 9 | 11 | 13 |
| *_link z12-15 | | | | | | 1.7 | 2.3 | 2.6 | 3.6 | | | | |
| *_link z16+ | | | | | | | | | | 5.7 | 6.8 | 8.5 | 9.5 |
| tertiary/tertiary_link z10+ | | | | 1 | 1.2 | 1.6 | 2 | 2.7 | 3.8 | 5 | 6.5 | 9 | 10.5 |
| unclassified z11+ | | | | | 0.8 | 1.2 | 2 | 2.7 | 3.8 | 5 | 6.5 | 9 | 10.5 |
| residential/living_street | | | | | | 1.4* | 1.6 | 2 | 2.6 | 4.5 | 6 | 9 | 10.5 |
| service z12+ | | | | | | 0.4 | 0.6 | 1 | 1.5 | 2.5 | 4 | 5.5 | |
| service driveway/parking_aisle/alley z12+ | | | | | | 0.3 | 0.4 | 0.8 | 1 | 1.7 | 3 | 4 | |
| busway z15+ | | | | | | | | | 1.5 | 2.5 | 4 | 5.5 | |
| road z14+ | | | | | | | | 0.6 | 1.3 | 1.7 | 2.5 | 3 | 4 |
| track z14+ (línea continua) | | | | | | | | 0.7 | 1.1 | 1.8 | 2.5 | 4 | 6.5 (z20+: 8) |
| pedestrian z12+ | | | | | | 1* | 1.5* | 3 | 4.5 | 7.5 | 12 | 17 | |
| footway z12+ | | | | | | 0.5* | 0.8* | 1 | 1.2 `4_2` | 1.4 `5_2.5` | 1.7 `7_3` | 2.5 `10_4` | |
| cycleway z12+ | | | | | | 0.8* | 1.2 `9_1.5`* | 1.5 `14_2.5` | 2 `16_3` | 2.5 `19_4` | 3.6 `25_5.5` | 4.5 `33_7` | |
| path z12+ | | | | | | 0.5 `0.4_0.4`* | 0.8 `0.8_0.8`* | 1 `1_1` | 1.3 | 1.6 | 2 | 3 | |
| steps z15+ (`1_2`) | | | | | | | | | 3 | 5 | 7.5 | 9 | |

`*` = solo con `moreDetailed=true`. residential z12-14 usa `#C6C6C6` y z15+ `#C2C2C2` (noche ≤z15 `#535353`); residential visible desde z13 (z12 solo con moreDetailed). En `<order>`, `highway=service` con `moreDetailed=false` queda oculto bajo z11, y `driveway`/`parking_aisle`/`alley` bajo z15. Track siempre por debajo de residential.

Modificadores comunes a las carreteras: `tunnel=yes`/`covered=yes` → punteado `4_4` cap BUTT (desde z12 en el bloque z6-15/links, z14+ en el resto, z15+ en track/steps); `bridge=yes` → casing `color_0` (#8a8a8a/#4a4a4a) con anchos propios desde z14/z15 según clase; `construction=yes` → punteado `6_3` (z≤15) / `8_4` (z16+) cap BUTT y color de construction; `access=no/private` en unclassified/residential/service → overlay `#b8b8b8`/`#4a4a4a` punteado `6_1.5` (service `4_1`); en track/pedestrian/steps con access=no/private la vía se deshabilita (`disable="true"`) si `hideAccess=false`.

### 7.3 Otras líneas

| Elemento | minzoom | Detalle |
| --- | --- | --- |
| GPX trackline (`osmand=file_trackline`) | 2 | `#55ff0000` cap ROUND + flechas `arrow_triangle_white_nobg` (step 40 z13-16, 50 z17+); override por `color=*` (white/yellow → flecha negra); anchos 1.5→6 |
| GPX routeline (`osmand=file_routeline`) | 2 | `#55ff00ff` punteado (5_1/8_1/11_1/13_1) |
| `natural=coastline_broken` / `coastline_line` | 1 / 5 | `#111111` / `#cc999999` (noche `#cc375E86`) |
| `waterway=river`/`canal` (+locks) | 10 | color agua + casing blanco `color_2=#ffffff` punteado `4_2` (noche `#7340D9`); anchos 1.2 (z≤10), 2, 3, 5, 6, 10, 12 (z18+); flechas `arrow_blue_big` desde z13 (river, step 130/140/150) y z15 (canal, 150); `intermittent=yes` oculto ≤z14 |
| `waterway=stream` | 15 | anchos 1→4 (z20+); flechas desde z16 (step 130/140/150, 190 si intermittent) |
| `waterway=wadi` | 16 | punteado creciente 4.5_3→12_7, anchos 1.3→4 |
| `waterway=ditch`/`drain` | 16 | anchos 0.8→2.3 |
| `railway=rail` | 7 | `#777777` + blanco `#ffffff` (noche `#454545` ≤z8, `#888888` z9+); travesaños punteados `3_4.5`/`5_7`/`0_7_5_1`; puente z14: negro 7 + blanco 5 + gris `#999999` 1 punteado `12_8_1_0` |
| `railway=tram` / `subway` / `light_rail` / `narrow_gauge` | 13 / 13 / 13 / 13 | `#444444`/`#777777`… anchos 1→2 |
| `railway=monorail` / `funicular` | 15 | 3 punteado `2_3` / `#146159` ancho 2 (túnel: 5 punteado `5_3` + `#cccccc`) |
| `aeroway=runway` / `taxiway` (línea) | 11 / 12 | `#a99dba` (noche `#6d6378`), anchos 2→18 / 1-4 |
| `power=line` / `minor_line` | 14 / 15 | `#999999` (noche `#777777`), 0.6→0.9 / 0.3 |
| Fronteras `admin_level=0-2` / `3-4` | 2 / 4 | doble línea: outer `#33555555` (noche `#50555555`) + inner `#99777777` (noche `#aa777777`); anchos hasta 12+2; nivel 3-4 punteado `6_1` |

## 8. Puntos e iconos (`<point>`)

**No hay ningún icono.** La sección `<point>` solo genera el primitivo de punto para que `<text>` muestre el nombre (comentario en el XML: "sin iconos"): `place=*` desde z1, `natural=water` z12, `natural=bay` z12, `natural=wetland` z13, `amenity=fountain` z17. Todos los POI (amenity, shop, tourism, leisure…) solo existen en `<order>` (order 128) sin icono ni, salvo excepciones de §9, etiqueta.

## 9. Textos (`<text>`), por zoom

Base: color `#000000`, wrap 20, halo radius 2 (`$textHaloRadiusDay/Night`); noche texto `#ffffff` halo `#77777777`. Todo dentro de `hideText="false"` salvo leyenda y waypoints. Tamaños de vía: 12 (z≤14) → 13 → 14 → 16 → 18 (z18+).

| Categoría | Elemento | minzoom | Color / estilo |
| --- | --- | --- | --- |
| Vías (ref) | motorway/trunk z8, primary z10, secondary z12, tertiary z13, unclassified z14 (`nameTag=ref`) | 8-14 | `#fff38c` negrita, halo 4 del color de la vía, size 12, minDistance 150 |
| Vías (nombre) | motorway/trunk/primary/secondary + links | 13 | blanco sobre la vía (`textOnPath`), halo del color de vía |
| Vías (nombre) | tertiary+links z15 (z14 con moreDetailed); unclassified, residential, service, busway, living_street, rest_area, pedestrian | 14 | igual; halo `$tertiaryRoadColor` en unclassified |
| Vías secundarias | track, cycleway, path, bridleway, footway, steps, rail/tram/light_rail/monorail/funicular, road | 14 | `#000000` (noche `#cccccc`), halo `#ddffffff` (noche `#aa444444`) |
| Nudos | `highway=motorway_junction` | 13 | `#00008b` (noche `#dcdcff`), halo 1, wrap 16; ref en car z13 / name+ref z14+ |
| Países | `place=continent` z1-2; `place=country` z3 | 1 / 3 | `$placeCountryTextColor` `#666666` (noche `#d99b42`), halo 3; sizes 12→16 negrita; `textOrder` según `population_rounded` (1.5e9→100) |
| Estados/regiones | `place=state` z3-10 (variantes ref/`osmand_large_state`), region/province z6, county z9-12 | 3 | `#9d6c9d` itálica (noche `#d99b42`) |
| Ciudades/pueblos | `place=city` z5 (size 13→14→18; capital: 13/20/22, textOrder 11), `place=town` z8 (16), `place=village` z11 (14; 16 z16+, 17 z17+) | 5 / 8 / 11 | `$placeCityVillageTextColor` `#000000` (noche `#E5E5E5`), halo `#ccebe7e4`/`#77444444`, negrita, dy -4; textOrder por población |
| Barrios | suburb z11-17 itálica, borough z12, neighbourhood z13, quarter z13, city_block z14, hamlet z12 | 11-14 | `#333333` (noche `#ffffff`), halo 3 `#ffffff`/`#77777777`, size 13-17 |
| **Sin nombre** | `place=farm`, `isolated_dwelling`, `locality` | — | deliberadamente sin etiqueta (PR #19) |
| Islas | `place=island`/`atoll` z5 (size por `area_rounded` si prominente, 14 desde z11), `islet` z13 | 5 / 13 | color ciudad, itálica |
| Agua | `place=ocean`/`sea` z1; `natural=water`: reservoir/lake z12 sin importar área, resto por `area_rounded` (z12 ≥2048000 … z17 cualquiera); `natural=bay` z12; `waterway=river` z12, `canal` z13, `lock` z14, `stream` z15, `wadi` z16, `dam`/`dock` z15, `ditch`/`drain` z16; `natural=spring` z16; `landuse=water`/`reservoir`/`basin` z13; `leisure=marina` z14 | 1-17 | `#2375aa` (noche `#90e4ff`), halo `#ddf1fd`/`#aa003153`; ríos/canales `textOnPath` minDistance 80. Agua pequeña (`water=basin/pond/pit/oxbow/drain/ditch`) y `amenity=fountain` solo nombre desde **z17** |
| Mar | `place=sea`/`ocean` siempre desde z1 | 1 | (PR #19: visibles en todos los zooms) |
| POI mínimos | `amenity=fuel/parking/charging_station/taxi` z17, `highway=services` z16, `junction=yes` z17 | 16-17 | `#0066ff` (noche `#bff8ff`) |
| Tiendas | `shop=convenience/department_store/supermarket` | 17 | `#902f00` (noche `#ffcbb2`) |
| Transporte | `railway=station` z15 negrita, `amenity=bus_station` z15, `public_transport=station` z14, `amenity=ferry_terminal` z16, `railway=halt` z15, `railway=tram_stop` z16, `aerialway=station` z15 | 14-16 | `#6666ff` (noche `#d4d4ff`) |
| Metro | `railway=subway_entrance` z17 negrita + variantes `color_red/orange/…/black` (`$subwayText*Color`) | 17 | por línea de metro |
| Áreas | cementerio/graveyard/park/industrial/residential z14, wastewater_plant z15 | 14-15 | itálica `#204800` (noche `#c3e8c3`), halo `#d3e6c4` |
| `landuse=residential` (etiqueta) | | 13 | `#000000` / noche `#ffffff` |
| Militar | `landuse=military` z17, `military=danger_area` z15 | 15-17 | `#990d2a` (noche `#ffd3dc`) |
| Religión | `amenity=place_of_worship` z16, `amenity/historic=monastery` z14 | 14-16 | `#330000` (noche `#ffd1d1`), halo `#bbffffff` |
| Otros POI/áreas | `tourism=attraction` z15, `tourism=artwork` z16 | 15-16 | `#a01300` negrita (noche `#ffcaad`) |
| Naturaleza | `natural=beach` z14, `natural=volcano` z13 (+`ele`/`ele_feet` según `eleUnits`, sizes 11→15), `natural=cave_entrance` z16, `natural=coastline`/`land` z3, `route=ferry` z3 | 3-16 | beach `#6b5130`; volcano/cueva `#654321`; costa `#883287` halo `#aaffffff`; ferry `#7330a7` onPath |
| **Picos `natural=peak`: sin nombre en ningún zoom** | | — | (decisión de diseño) |
| Aeródromos | `aeroway=aerodrome` z11 si tiene iata/icao/faa/large_aerodrome (si no, z15; `abandoned=yes` oculto z9-15), `aeroway=taxiway` ref z15 onPath, `aeroway=terminal` z15 | 11-15 | `#0748a8` (noche `#c3dbff`); taxiway/terminal `#333333` |
| Entradas/direcciones | `entrance` z19 (ref), `highway=elevator` z19, `addr:flats` z18+, `military=barracks` z16 | 16-19 | `#404040`/`#555555` (noche `#ffffff`) |
| Waypoints GPX | `osmand=file_waypoint` z11+ | 11 | `#000000` halo `#ffc8c8` (noche `#dddddd`/`#5f0000`) |

## 10. Cambios recientes que explican el estado actual

- PR #18: fuera piscinas y vegetación no esencial (bosques, matorral, huertos, césped…); solo queda verde en parques/reservas.
- PR #16 + commits: `highway=track` línea continua marrón claro desde z14, siempre bajo residential; hidrograma pequeño (ditch/drain) retrasado a z16, después de las tracks.
- PR #20: `highway=unclassified` se pinta como tertiary desde z11 (0.8/1.2 en z11-12, igual que tertiary desde z13).
- PR #19 + commits: nombres de `place=*` restaurados vía sección `<point>`; agua con nombre desde z12 progresivo por área; mares/océanos desde z1; `place=farm/isolated_dwelling/locality` y `natural=peak` sin nombre; pequeñas masas de agua y fuentes solo desde z17.
- PR #22: texto de ciudades y pueblos igual que el estilo default de OsmAnd (colores `$placeCityVillageTextColor` y halo propio).
- PR #6: edificios ocultos (polígono transparente desde z16) y verde pastel unificado.
- PR #11: eliminados todos los iconos POI y las etiquetas de paradas de bus.
- PR #8/#12: sin bordes en áreas (piscinas, edificios religiosos) ni vallas/muros.
- Commit 3820335: parques naturales (`boundary=*`) desde z8 y agua a order 90 (mar por encima de todo).
- Commit 45f7ac2/40c35ae: verde de parques progresivo por bandas desde z8.
- Commit 0948cf9: revertido el residential más oscuro; se mantiene `#f4f4f4`/`#1a1a1a`.
