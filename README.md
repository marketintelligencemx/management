# management

Herramientas de gestión interna de Meridian Consulting & Solutions.

Herramienta actual: checklist de arranque de operaciones (`index.html`). Cuatro canales (Administrativo, Branding & Marketing, Comercial, Operativo) con estados, fechas límite y responsables. Funciona como PM inicial de la firma.

Página publicada: `https://marketintelligencemx.github.io/management/`

## Correr en local

Abrir `index.html` directo en el navegador, o:

```bash
python3 -m http.server 8000
# http://localhost:8000
```

## Publicar en GitHub Pages

El repo `marketintelligencemx/management` ya existe y está vacío. Desde la carpeta del proyecto:

```bash
git init -b main
git remote add origin https://github.com/marketintelligencemx/management.git
git add -A
git commit -m "checklist de arranque: primera herramienta"
git push -u origin main
gh api -X POST repos/marketintelligencemx/management/pages -f 'source[branch]=main' -f 'source[path]=/'
```

Si el último comando pide permisos, activar Pages desde la web: Settings → Pages → Deploy from a branch → `main` → `/ (root)`.

Nota de acceso: el repo es público, así que la página y el código quedan visibles para quien tenga la URL, incluidos nombres de clientes y pendientes internos. Si se quiere restringir, se requiere repo privado con GitHub Pro o Team.

## Persistencia

- El estado (palomas, fechas, responsables, tareas agregadas) se guarda en `localStorage`: por navegador y por dispositivo. Cada persona ve su propia copia.
- Respaldo y traslado: botones Exportar e Importar en el footer (JSON).
- La sincronización real entre socios llega con la base de datos (ver `CLAUDE.md`, sección "Ruta a base de datos").

## Uso

- Clic en la casilla: pendiente → en proceso → hecha.
- Clic en fecha o responsable para cambiarlos.
- Doble clic en el texto para editar. `×` elimina con confirmación.
- `+ Agregar tarea` al final de cada grupo.

## Estructura

```
management/
├── CLAUDE.md        contexto para Claude Code
├── README.md
├── index.html       checklist de arranque (autocontenido)
└── assets/          emblema y logos oficiales
```
