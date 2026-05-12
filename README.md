# La Pregunta Define la BD

> Una webapp didáctica para enseñar diseño de bases de datos partiendo de **preguntas de negocio reales** — no de tablas.

**Para quién**: arquitectos, product managers, dueños de producto, equipos no-técnicos que necesitan entender por qué su BD responde unas preguntas y no otras.

**El método** que enseña en 4 pasos:

1. Tomas una pregunta de negocio en español natural
2. La descompones en entidades (tablas + columnas)
3. Marcas qué tienes (verde), qué es decisión de diseño (amarillo), qué falta (rojo)
4. Decides arquitectura: ¿calcular en runtime? ¿materializar? ¿snapshot histórico? ¿Es crítico para ML?

---

## Qué hace la app

- **5 preguntas pre-cargadas** sobre una BD de coaching (zona-ai) con animación paso a paso
- **Análisis en vivo**: escribes una pregunta de negocio cualquiera y Claude la descompone
- **Esquema custom**: pega tu DDL/SQL, descripción libre, o sube **imagen de tu ERD** (Claude Vision) → la app aprende tu BD y responde preguntas sobre ella
- **5 capas de respuesta por pregunta**:
  - **EN CRISTIANO** — traducción para gerentes con ejemplo concreto
  - **¿Guardar o calcular?** — decisión arquitectónica con lente ML-ready
  - **Dashboard imaginado** — Claude propone gráficos SVG (line/bar/funnel/kpi/heatmap) con insight accionable
  - **¿Qué falta?** — roadmap de tablas/columnas faltantes
  - **SQL** — query ejecutable

---

## Cómo correrlo

**No requiere build, ni node, ni servidor.** Es un solo HTML.

### Opción A — Doble click

1. Clona el repo
2. Abre `index.html` con tu navegador (Chrome/Safari/Firefox)
3. Header → botón "API key" → pegas tu key de Anthropic → guardar
4. Listo

### Opción B — Pre-cargar la API key (recomendado para uso recurrente)

1. Copia `local-config.example.js` → `local-config.js`
2. Edita y pega tu key real
3. Abre `index.html` — la key ya queda cargada al toque

> `local-config.js` está en `.gitignore`. **Nunca se sube al repo**.

### ¿No tienes API key?

Crea una gratis en [console.anthropic.com/settings/keys](https://console.anthropic.com/settings/keys).

**Costo estimado de uso real**: ~$0.01-0.02 por pregunta analizada. Una sesión completa de taller (~10 preguntas) cuesta ~$0.15.

---

## Estructura

```
/
├── index.html                       # La app (única que importa)
├── local-config.example.js          # Template para tu API key (copia a local-config.js)
├── local-config.js                  # TU api key (gitignored, no se sube)
├── README.md
├── LICENSE                          # MIT
├── .gitignore
│
├── docs/                            # Material complementario del taller
│   ├── 01-diagrama-pregunta-uno.md  # ERD Mermaid + layout ASCII de la pregunta seed
│   ├── 02-guion-15min.md            # Script narrado de los primeros 15 min del taller
│   └── 03-queries-en-vivo.sql       # Queries postgres ejecutables
│
├── ejemplos/                        # Schemas de prueba + respuestas reales de Claude
│   ├── 01-ddl-ecommerce.sql         # Para probar el tab "DDL/SQL"
│   ├── 02-descripcion-clinica-dental.txt  # Para probar el tab "Descripción"
│   └── *.json                       # Respuestas reales de Claude como referencia
│
└── versions/                        # Versiones anteriores (histórico)
    └── v1-pre-architecture-ml.html
```

---

## Stack técnico

- **React 18** (UMD via CDN, sin build)
- **Tailwind CSS** (Play CDN)
- **Babel Standalone** (transpila JSX inline)
- **Claude Sonnet 4.6** (Anthropic API directa desde browser)
- **SVG hand-coded** para todos los gráficos (cero dependencias, máximo control)

Llamadas a Claude:
- `analyzeWithClaude` — descompone pregunta de negocio en entidades + SQL
- `processSchema` — convierte DDL/texto/imagen del cliente en knowledge base reutilizable (Claude Vision para imágenes)
- `analyzeArchitecture` — decisión guardar/calcular/snapshot con lente ML
- `analyzeVisualization` — sugiere gráficos con mockData realista

Prompt caching activo en el system prompt para amortizar costo en sesiones de varias preguntas seguidas.

---

## Decisiones técnicas conscientes (trade-offs)

Este proyecto es deliberadamente un **single-file HTML sin build step**. Eso impone trade-offs que merecen estar documentados:

### Tailwind Play CDN

Se usa `cdn.tailwindcss.com` (Play CDN), que es un compilador JIT en el browser. Tailwind oficialmente recomienda no usarlo en producción porque añade latencia inicial (~500ms para compilar CSS al cargar). Acá se usa porque la alternativa rompe el "single file" — requeriría un build step con Tailwind CLI + un `output.css` aparte. Para taller didáctico y demos, esta latencia es aceptable. Si quieres producción real, reemplaza el script por Tailwind compilado.

### Dependencias CDN con SRI

React 18.3.1, ReactDOM 18.3.1 y Babel Standalone 7.26.4 están pineadas a versiones específicas con hashes **SRI (Subresource Integrity, sha384)**. Si alguien compromete unpkg.com, el browser detecta que el contenido no coincide con el hash y NO ejecuta el script. Protege contra supply-chain attacks típicos.

Tailwind Play CDN NO tiene SRI porque su contenido cambia dinámicamente — es un compromiso explícito.

### Browser-direct a la Anthropic API

Las 4 capas de análisis (pregunta, schema, arquitectura, visualización) llaman a `https://api.anthropic.com/v1/messages` directamente desde el browser usando el header oficial `anthropic-dangerous-direct-browser-access: true`. Esto evita necesitar un backend proxy. El trade-off: tu API key vive en el browser. Acceptable para uso personal/taller. Para producción multi-usuario hay que proxiar via backend.

### App como single component

El componente `App` tiene ~580 líneas. En un proyecto convencional esto se rompería en sub-componentes (`LandingScreen`, `QuestionScreen`, `PanelManager`). Acá se mantiene monolítico porque el archivo entero es 1 solo HTML — sub-componentes no aportan modularidad real cuando ya estás en un solo archivo. Si haces fork con build pipeline, separar es trivial.

### Babel Standalone en el browser

JSX se transpila en el browser al cargar la página (~200ms extra en la primera carga). En cualquier proyecto serio, eso debería ser un build step offline. Acá se acepta el costo para mantener el "doble click y abre" como UX de instalación.

---

## Historia de auditoría

Este código fue auditado contra patrones típicos de vibe-coding (45% del código generado por IA tiene vulnerabilidades, según datos 2025-2026). Fixes aplicados:

- ✓ **Race condition** en `setTimeout` del reveal animation — ahora con `useRef([])` + cleanup en `reset()` y `useEffect` de unmount
- ✓ **Duplicación de fetch a Claude** — extraído helper único `callClaudeJSON` reutilizado por las 4 capas (eliminó ~80 líneas duplicadas)
- ✓ **SRI hashes** en dependencias CDN — pineadas a versión específica con sha384
- ✓ **Magic numbers** (`1400`/`2900`/`4200` del reveal) — extraídos a constante `REVEAL_TIMING_MS`
- ✓ **Cero secrets hardcodeados** verificado con grep
- ✓ **Cero XSS** verificado (sin innerHTML, eval, ni dangerouslySetInnerHTML)
- ✓ **Cero console.log de debug** verificado
- ✓ **Cleanup de event listeners** validado en `useViewport` y `ConnectionsSVG`

---

## Privacidad y seguridad

### Dónde vive tu API key

- En `localStorage["claude_api_key"]` del navegador donde abras el `index.html`
- Opcionalmente en `local-config.js` (gitignored — nunca se sube al repo)
- **Nunca** se manda a ningún servidor que NO sea `api.anthropic.com`

### Qué viaja a Anthropic

| Acción | Qué se envía |
|--------|--------------|
| Click pregunta pre-cargada | Nada nuevo — todo es local |
| Escribir pregunta libre + Analizar | El texto de tu pregunta + el system prompt con schema (zona-ai o tu BD custom procesada) |
| "Mi BD" → procesar DDL/descripción/imagen | El contenido pegado/subido tal cual, sin filtros |
| Click "¿Guardar o calcular?" sobre una pregunta libre | Las entidades + el texto de la pregunta |
| Click "Dashboard imaginado" sobre una pregunta libre | Las entidades + el texto de la pregunta |

**Regla de oro**: si lo pegaste en la app, asume que llegó a Anthropic.

### Protecciones de defensa en profundidad

- **Content-Security-Policy** estricta en el `<meta>` del HTML — limita `connect-src` a `api.anthropic.com`, `unpkg.com` (sourcemaps Babel), Google Fonts y `'self'`. Aunque hubiera XSS futuro en un fork, la key NO podría exfiltrarse a un dominio externo
- **SRI sha384** en las 3 dependencias críticas (React, ReactDOM, Babel) — si unpkg.com es comprometido, el browser no ejecuta el script
- **Sin innerHTML/dangerouslySetInnerHTML/eval** en código de la app (Babel usa eval para transpile JSX, ese es trade-off conocido del approach single-file)
- **Click-jacking** queda como gap conocido: el browser ignora `frame-ancestors` cuando viene via `<meta>` (solo lo respeta como HTTP header). Si servís la app desde nginx/Caddy/etc, agregá `X-Frame-Options: DENY`. En GitHub Pages no se puede setear headers, pero el riesgo es bajo porque la app no tiene login ni transacciones que un click-jack pueda explotar

### Si comiteás `local-config.js` por accidente

1. **Revoca la key INMEDIATAMENTE** en https://console.anthropic.com/settings/keys
2. Crea una nueva key y pégala en tu nuevo `local-config.js`
3. NO basta con borrar el archivo y volver a commitear — la key queda en `git log`. Si el push ya salió a GitHub, también borra el repo o reescribe la historia con `git filter-repo`
4. Verifica los logs de uso de la key vieja en console.anthropic.com para detectar abuso

### Cosas que NO aplican a este proyecto

Porque NO hay backend:
- ❌ SQL injection · ❌ Path traversal · ❌ CSRF · ❌ Mass assignment · ❌ Auth bypass

### Si vas a usar esta app para data sensible

NO es el caso de uso correcto. Esta app está diseñada para taller didáctico y exploración de schemas no confidenciales. Para producción con data real necesitarías:

- Backend propio que proxie a Anthropic (la key vive server-side)
- Auth de usuarios
- Anonimización automática del input antes de enviar
- Rate limiting per-user
- Audit log de qué se envió y cuándo

---

## Para usar en un taller

1. Antes del taller: corre `index.html` en local, configura tu key una vez
2. Si el cliente te comparte su BD en vivo: copia su DDL al tab "DDL/SQL" del modal "Mi BD" → procesar (~15s) → ya queda activa
3. Si te trae screenshot del ERD: subes la imagen al tab "Imagen del ERD" → Claude Vision lo parsea
4. El cliente trae sus preguntas → las escribes en el input "EN VIVO" → animación + 5 capas de análisis

Lee `docs/02-guion-15min.md` para el script narrado de los primeros 15 minutos.

---

## Créditos

Construido por [Oscar Cuéllar (Profe Cuéllar)](https://github.com/ocuellar09) y [CrearIA](https://crearia.co), con asistencia de Claude.

Inspirado en la idea de que **una BD bien diseñada no responde TODAS las preguntas — responde LAS que el negocio decidió hacerse**.

---

## Licencia

MIT — ver [LICENSE](LICENSE). Úsalo en tus talleres, fork, modifica, vende cursos sobre esto. Solo te pido que mantengas el crédito si lo redistribuyes.
