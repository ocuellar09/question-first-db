# Cómo grabar el `demo.gif` del README

El GIF arriba del README es lo que más convierte visitante pasajero en ★ (star) en GitHub. Este doc te deja todo armado para grabarlo en ~5 minutos.

## Setup (una sola vez)

```bash
# 1. Instalar gifski (mejor calidad/peso que ffmpeg solo)
brew install gifski

# 2. Asegúrate que ffmpeg también esté
brew install ffmpeg
```

## Libreto del GIF — exactamente 10 segundos

Abre la app en https://ocuellar09.github.io/question-first-db/ y maximiza la ventana (no full-screen, solo grande — proporción 16:10 o 16:9 con la app centrada). Si te aparece el tour de bienvenida, **ciérralo antes** de empezar la grabación.

Posiciona el mouse fuera de la ventana antes de empezar. Sigue esta secuencia con metrónomo mental:

| Segundo | Acción | Qué se ve |
|---------|--------|-----------|
| 0.0 – 1.5 | (nada — solo landing visible) | Hero "La pregunta define el diseño..." + 5 preguntas |
| 1.5 – 2.0 | Mouse sobre la card "Pregunta 1 — Top clientes (e-commerce)" | Hover effect amber |
| 2.0 | **Click** la card | Comienza animación de reveal |
| 2.0 – 5.5 | Esperar la animación | Pregunta aparece arriba, después PlainSummary, después cajas verde/amarillo apareciendo una por una |
| 5.5 | Scroll suave hacia abajo (1 wheel) | Ahora se ven los 5 botones de capas |
| 6.0 | **Click** botón grande amarillo **"EN CRISTIANO"** | Modal abre con "EJEMPLO CONCRETO" en bloque verde |
| 6.5 – 7.5 | Quedarse en el modal | Se lee el ejemplo de María Gómez con su data |
| 7.5 | **Click** la X del modal | Cierra |
| 8.0 | **Click** botón violeta **"¿Guardar o calcular?"** | Modal abre **instantáneo** (está hardcodeado en pre-cargadas) |
| 8.5 – 10.0 | Quedarse en el modal | Se ve "SNAPSHOT HISTÓRICO" + badge **ML: CRÍTICO** + reasoning |

> **Tip importante**: usá **pre-cargadas** (no input libre) para evitar la latencia de Claude (~6s) que arruinaría el ritmo del GIF.

## Grabación

### En macOS (más simple)

1. `Cmd + Shift + 5` → seleccionar **"Grabar porción seleccionada"** (el segundo icono de la barra)
2. Arrastrá el rectángulo sobre la ventana del browser (sin incluir la barra del navegador si querés un look más limpio)
3. **Antes de presionar Record**, en "Options" → "Timer" → poné 3 segundos para tener tiempo de posicionar el mouse
4. **Record** → ejecutá el libreto de 10s arriba
5. `Cmd + Esc` o el botón del menú bar para parar
6. Sale el video como `Screen Recording …mov` en Desktop

### Convertir a GIF optimizado

```bash
# 1. Convertir MOV → frames PNG (20 fps es suficiente, calidad buena, peso manejable)
mkdir -p /tmp/demo-frames
ffmpeg -i ~/Desktop/Screen\ Recording*.mov \
  -vf "fps=20,scale=1200:-1:flags=lanczos" \
  /tmp/demo-frames/%04d.png

# 2. Frames → GIF con gifski (palette adaptativa, mejor que ffmpeg crudo)
gifski -o docs/demo.gif --quality 90 --fps 20 /tmp/demo-frames/*.png

# 3. Limpiar
rm -rf /tmp/demo-frames

# 4. Verificar peso (debería quedar entre 1-4 MB)
ls -lh docs/demo.gif
```

Si el GIF supera 5 MB, reducí:
- `scale=900:-1` en vez de `1200` (ancho menor)
- `fps=15` en vez de `20`
- `--quality 80`

## Commit y push

```bash
git add docs/demo.gif
git commit -m "docs: add 10s demo gif to README"
git push
```

GitHub Pages no necesita rebuild — el GIF se carga directo desde el repo via raw URL en el README.

## Consejos finales

- **Hacé 2-3 takes** y elegí el mejor. La animación de reveal es la parte más vistosa, asegurate que se vea limpia.
- **Cursor visible** en macOS: en System Settings → Accessibility → Pointer → "Pointer size" subido a un nivel intermedio (3-4) hace que el mouse se vea en el GIF sin verse desproporcionado.
- **Ocultá el dock** (`Cmd + Opt + D`) antes de grabar si está en el camino.
- **Modo oscuro del browser**: la app es dark — si tu sistema también está en dark, el frame se ve consistente.
- **Si el peso es alto**: probá `gifsicle -O3 docs/demo.gif -o docs/demo.gif` para una segunda pasada de optimización.

## Alternativa: si querés hacerlo con Playwright (automatizado)

Si más adelante querés regenerar el GIF programáticamente cuando cambies la UI, podés hacer un script `scripts/record-demo.mjs` con Playwright que abra la app, ejecute las acciones, grabe video, y convierta a GIF. Eso es overkill para hoy, pero útil si el GIF se queda desactualizado seguido.

```bash
# Setup hipotético
npm init -y && npm install -D playwright
npx playwright install chromium
# Después corres: node scripts/record-demo.mjs
```

Para un repo público estable con poca iteración visual, la grabación manual es lo correcto.
