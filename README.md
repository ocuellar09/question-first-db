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

## Privacidad y seguridad

- La API key vive **solo en tu navegador** (`localStorage` + opcionalmente `local-config.js` local)
- **Nunca** se manda a ningún servidor que no sea Anthropic
- Las preguntas que escribes SÍ viajan a Anthropic — si son sensibles, considéralo
- El esquema que cargues a "Mi BD" se manda a Anthropic para procesarlo. Si tu schema es confidencial, NO subas la versión con datos reales — usa una versión anonimizada

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
