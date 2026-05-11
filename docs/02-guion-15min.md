# Guión — Primeros 15 minutos del taller

**Audiencia:** Directivas de Prestigio (dueños del producto MIA)
**Objetivo del bloque:** Enseñar el método "la pregunta define el diseño" usando la BD de zona-ai/MIA como ejemplo seed, antes de aplicarlo a la BD propia de Prestigio.

---

## Minutos 0-2 — APERTURA (sentar la tesis)

**Tú dices, sin pizarra todavía:**

> "Antes de tocar ninguna tabla, ninguna columna, ningún script — necesito que entiendan UNA cosa: el diseño de su base de datos NO es una decisión técnica. Es la consecuencia de una pregunta. Y si nunca se hicieron la pregunta, la base no la responde. Así de simple."

> "Lo voy a probar con algo que ustedes conocen mejor que yo: MIA. Su producto. Su agente. Vamos a hacerle UNA pregunta de negocio a la base de datos de MIA, y van a ver cómo el modelo responde — o no — según qué tan bien pensamos la pregunta."

**Pausa. Respira. Que sientan que esto es trabajo serio, no demo.**

---

## Minutos 2-5 — LA PREGUNTA (paso 1 del método)

**Escribes en la pizarra/Excalidraw, en español natural, sin tecnicismos:**

> ### *"De los coachees que iniciaron el programa con MIA, ¿cómo va el avance de cada uno?"*

**Tú dices:**

> "Una pregunta inocente. La haría cualquier gerente. Cualquier coach. Hasta el propio coachee. Pero acá viene lo importante — ANTES de tocar SQL, vamos a descomponer la pregunta. Porque cada pregunta esconde decisiones."

> "Fíjense en las palabras: 'coachees', 'iniciaron', 'programa', 'avance'. Cada palabra es una entidad o una métrica. Vamos a ponerlas en cajas."

---

## Minutos 5-9 — DIBUJAR LAS CAJAS (pasos 2 y 3 del método)

**Empiezas a dibujar UNA caja por término que aparece en la pregunta:**

1. Dibujas `Coachee` → tú dices: "¿dónde vive cada coachee en MIA? En la tabla **course_enrollments**. Acá está su teléfono, su nombre, cuándo se inscribió."

2. Dibujas `Programa` → tú dices: "el programa es **courses** + **course_modules**. Un programa tiene módulos ordenados — eso es contenido."

3. Dibujas `Inicio` → "esto ya empieza a doler. ¿Qué es 'iniciar'? ¿Inscribirse? ¿Aceptar términos? ¿Mandar el primer mensaje? La BD tiene **enrolled_at** y **status='active'**. Eso me da una respuesta — pero ojo, la respuesta DEPENDE de qué definamos como 'iniciar'."

4. Dibujas `Avance` → "y acá viene la trampa. ¿Qué es 'avance'? Acá la BD me da dos cosas, y son MUY distintas: **student_progress** (qué módulos completó, cuándo) y **conversation_insights** (qué tan profunda fue la conversación)."

**Cierras esta sección con:**

> "¿Ven lo que acabamos de hacer? La pregunta tenía 4 palabras cargadas. Cada una me obligó a tomar una decisión. ESO es modelar."

---

## Minutos 9-12 — EL MOMENTO AMARILLO (el zinger)

**Tú dices, casualmente, como si se te ocurriera:**

> "Pregunta tonta: ¿y si quiero ver el avance del coachee en un número del 1 al 10?"

**Pausa. Que ellos procesen. Mira a la mesa.**

> "Acá viene lo interesante. MIA NO TIENE eso. La columna **conversation_insights.evolution_notes** es texto. Es narrativa. MIA está diseñada para acompañar conversacionalmente, no para producir KPIs ejecutivos."

> "¿Eso es un error? NO. Es una decisión de diseño. Crearia decidió que el coaching es narrativa, no número. Porque la pregunta que nos hicimos al construir MIA fue 'cómo acompaño', no 'cómo califico'."

> "Ahora la pregunta es para USTEDES: ¿qué quieren ver? ¿Una narrativa enriquecida o un dashboard de KPI? Porque la respuesta determina qué tablas le faltan a MIA — y eso es upgrade de producto."

**Acá pausas y dejas que ellos hablen. Este es el momento de discovery.**

---

## Minutos 12-15 — TRANSICIÓN A SU BD

**Cierras con:**

> "Lo que acabamos de hacer con MIA, ahora lo vamos a hacer con su propia base. Ustedes trajeron preguntas. Vamos a tomar las preguntas una por una, vamos a dibujar las cajas como acabamos de hacer, y vamos a ver qué responde su modelo y qué no."

> "No es un examen. Es un descubrimiento. Y al final de este taller van a salir con DOS cosas: las preguntas que su BD ya responde (con las queries listas), y las preguntas que su BD no responde — que son su próximo sprint de producto."

> "Empezamos. ¿Quién tiene la primera pregunta?"

---

## Zingers (frases que pegan, úsalas cuando sientas el momento)

- "El SQL es la última decisión, no la primera."
- "Una BD bien diseñada no responde TODAS las preguntas — responde LAS que el negocio decidió hacerse."
- "Si nunca te hiciste la pregunta, no le reclames a la base por no responderla."
- "Una columna en JSON es una decisión postergada."
- "El esquema es la huella de tus preguntas pasadas. Si quieres futuro distinto, pregunta distinto."

## Reglas de oro durante el taller

1. **NO empieces por la tabla.** Siempre empieza por la pregunta en español.
2. **NO juzgues la BD del cliente.** Cada gap es discovery, no falla.
3. **Cuando aparezca un gap, dibújalo CON LÍNEA PUNTEADA.** Visual = recordable.
4. **Después de cada pregunta, escribe en una hoja aparte: "Roadmap de datos".** Eso es el entregable real del taller.
5. **No saques laptops antes del minuto 30.** Pizarra primero. SQL después.
