# management

Herramientas de gestión interna de Meridian Consulting & Solutions (MCS).

Herramienta actual: checklist de arranque de operaciones (`index.html`), publicada como GitHub Page. Funciona como PM inicial de la firma mientras no hay base de datos.

## Stack y principios

- HTML, CSS y JS vanilla. Un solo archivo autocontenido por herramienta. Sin build, sin frameworks, sin dependencias.
- Publicación: GitHub Pages desde `main`, raíz del repo `marketintelligencemx/management`. URL: `https://marketintelligencemx.github.io/management/`.
- Tipografías vía Google Fonts: Newsreader, Instrument Sans, IBM Plex Mono. Los TTF oficiales existen en el kit de marca por si algún día se autohospedan.
- Nuevas herramientas: un archivo `nombre.html` en la raíz o carpeta propia. `index.html` se mantiene como la herramienta principal.

## Copy

- Español, sentence case, sin exclamaciones, sin em dashes (usar `·` o dos puntos).
- Literal y pragmático. Sin títulos conceptuales ni frases de marketing.

## Marca (obligatoria en toda herramienta nueva)

Colores:
- Tinta `#0E0D0B` texto primario. Nunca negro puro.
- Naranja `#E84E1B` único acento (~5%): líneas, kickers, datos clave, itálicas. Nunca fondo de textos largos.
- Gris cálido `#8B857B` texto secundario. Nunca grises fríos.
- Hueso `#F6F4EF` tarjetas y paneles.
- Blanco `#FFFFFF` fondo base.
- Línea `#E5E0D6` bordes y divisores.

Tipografía:
- Newsreader (serif): titulares, weight 500.
- Instrument Sans: cuerpo.
- IBM Plex Mono: kickers, etiquetas, datos, tablas, footers. Mayúsculas con tracking.

Reglas:
- Cero border-radius. Sin sombras.
- Emblema (tres líneas naranjas) arriba a la derecha. La E de MERIDIAN son las tres líneas: no reconstruirla con otra fuente.
- Un solo elemento oscuro por vista como máximo.
- Estructura tipo: kicker mono naranja en mayúsculas, luego titular Newsreader, luego contenido en tarjetas hueso con borde `#E5E0D6`.
- Assets oficiales en `assets/` (emblema, logo principal, logo MCS compacto).

## Arquitectura de index.html

- `SEED`: estado semilla completo (canales → grupos → tareas). Cada tarea: `{ id, t, d, s, r, f }` donde `s` es `todo | prog | done`, `r` es responsable (`Fray`, `Pancho` o `Angel`, en ese ciclo al hacer clic), `f` es fecha límite ISO `YYYY-MM-DD` o vacío.
- `store`: adaptador de persistencia con tres backends en cascada y un solo contrato: `async get(key) -> string | null`, `async set(key, value) -> bool`.
  1. `window.storage` (artefactos de Claude)
  2. `localStorage` (GitHub Pages y navegador)
  3. Memoria (solo sesión)
- Llave de estado: `meridian-arranque-v2`. El estado completo se guarda como un solo JSON.
- `syncMeta(state)`: los títulos de canales y grupos siempre vienen del código, nunca del estado guardado.
- `applyPatches(state)`: migraciones idempotentes sobre estado ya guardado. Cada cambio estructural incrementa `state.patch` y se aplica una sola vez. Parche vigente: 7. Un parche puede dar de alta un bloque completo con `seedGroup(id)`. Los parches toman los textos de `SEED` con `seedTask(id)`, para no duplicar copy entre semilla y parche.
- Exportar e importar JSON en el footer: respaldo y traslado de estado entre navegadores o dispositivos.

## Reglas al editar

- Nunca renombrar ids de tareas existentes: el estado guardado del usuario depende de ellos.
- Cambios de contenido (tareas nuevas de semilla, reasignaciones, textos): editar `SEED` y agregar un parche en `applyPatches` con el siguiente número, para que los usuarios con estado guardado reciban el cambio sin perder avance.
- Texto de usuario siempre escapado con `esc()` antes de insertarse en HTML.
- Todavía sin base de datos ni endpoints. La persistencia es local por navegador.

## Puerta de acceso

`index.html` abre con una pantalla de acceso. Usuario `MCS`, clave definida por la firma.

- El usuario no distingue mayúsculas, la clave sí.
- La credencial no viaja en texto plano: se compara contra un digest PBKDF2-SHA256 (150 000 iteraciones, sal `meridian-mcs-2026`) sobre `usuario:clave` en minúsculas el usuario.
- Al entrar se guarda `meridian-acceso = "1"` en `localStorage`. Un script en el `<head>` lo lee y agrega la clase `ok` al `<html>` antes de pintar, para que no haya parpadeo. El CSS oculta `#app` sin esa clase y oculta `.gate` con ella.
- Botón `Salir` en el footer: borra la bandera y vuelve a la puerta sin tocar el estado del checklist.
- Para cambiar la clave: recalcular el digest y reemplazar `GATE_DIGEST`.
  ```bash
  node -e "console.log(require('crypto').pbkdf2Sync('mcs:NUEVACLAVE','meridian-mcs-2026',150000,32,'sha256').toString('base64'))"
  ```

Lo que esta puerta sí hace: evitar que quien reciba la liga de rebote entre sin más. Lo que no hace: proteger la información. El repo es público, así que el contenido del checklist se lee directo en `index.html` desde GitHub sin pasar por la puerta. Protección real requiere repo privado con GitHub Pro o Team, o mover el contenido detrás de un backend con sesión.

## Limitación actual conocida

`localStorage` es por navegador y por dispositivo: cada socio ve su propia copia del estado. No hay sincronización entre personas hasta conectar base de datos. El puente manual es exportar e importar JSON.

## Ruta a base de datos (siguiente fase)

Cuando se conecte Supabase:

1. Implementar un cuarto backend del adaptador `store` con el mismo contrato, contra Supabase (el resto del código no cambia).
2. Esquema sugerido:
   - `checklist_state (id text primary key, payload jsonb, updated_at timestamptz)` para el snapshot compatible con el formato actual.
   - `checklist_events (id bigint generated always as identity, task_id text, campo text, valor_anterior text, valor_nuevo text, actor text, ts timestamptz default now())` para historial y timestamps por tarea.
3. Registrar un evento en cada mutación (estado, fecha, responsable, texto, alta, baja) además de guardar el snapshot.
4. Con eso se habilitan multiusuario real, bitácora y PMs por proyecto.
