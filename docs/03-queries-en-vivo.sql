-- ============================================================
-- TALLER PRESTIGIO - QUERIES EN VIVO CONTRA zona_ai
-- Filtradas SIEMPRE al tenant MIA (slug='mia')
-- ============================================================
-- Ejecutar contra:
--   Local: docker exec -it zona-ai-postgres-1 psql -U postgres -d zona_ai
--   EC2:   ssh ec2-user@52.23.238.116 'docker exec zona-ai-postgres-1 psql -U postgres -d zona_ai'
--
-- ANTES DEL TALLER: corre cada query una vez para confirmar que
-- devuelve algo. Si una query devuelve 0 rows, ajusta el filtro
-- o explica al cliente que MIA aun no tiene volumen en esa metrica.
-- ============================================================


-- ------------------------------------------------------------
-- 0. Sanity check: el tenant MIA existe y tiene cursos
-- ------------------------------------------------------------
SELECT
    t.id            AS tenant_id,
    t.slug,
    t.name,
    COUNT(c.id)     AS courses_count
FROM tenants t
LEFT JOIN courses c ON c.tenant_id = t.id
WHERE t.slug = 'mia'
GROUP BY t.id, t.slug, t.name;


-- ------------------------------------------------------------
-- 1. ZONA VERDE: cuantos coachees iniciaron el programa
--    Definicion de "iniciar" = status='active' (acepto terminos)
-- ------------------------------------------------------------
SELECT
    COUNT(*) AS coachees_iniciados
FROM course_enrollments ce
JOIN tenants t ON t.id = ce.tenant_id
WHERE t.slug = 'mia'
  AND ce.status = 'active';


-- ------------------------------------------------------------
-- 2. ZONA VERDE: detalle de cada coachee y su modulo actual
--    Esto es la respuesta DIRECTA a la pregunta seed.
-- ------------------------------------------------------------
SELECT
    ce.student_name,
    ce.student_phone,
    ce.enrolled_at,
    ce.status                            AS estado_matricula,
    c.title                              AS programa,
    COUNT(sp.id) FILTER (WHERE sp.status = 'completed')  AS modulos_completados,
    COUNT(cm.id)                          AS modulos_totales,
    ROUND(
        100.0 * COUNT(sp.id) FILTER (WHERE sp.status = 'completed')
        / NULLIF(COUNT(cm.id), 0),
        1
    )                                     AS pct_avance
FROM course_enrollments ce
JOIN tenants t           ON t.id = ce.tenant_id
JOIN courses c           ON c.id = ce.course_id
JOIN course_modules cm   ON cm.course_id = c.id
LEFT JOIN student_progress sp
       ON sp.enrollment_id = ce.id
      AND sp.module_id     = cm.id
WHERE t.slug = 'mia'
  AND ce.status = 'active'
GROUP BY ce.id, c.id
ORDER BY pct_avance DESC NULLS LAST;


-- ------------------------------------------------------------
-- 3. ZONA VERDE: en que modulo se quedo cada coachee (last touched)
-- ------------------------------------------------------------
SELECT DISTINCT ON (ce.id)
    ce.student_name,
    cm.order                AS modulo_orden,
    cm.title                AS modulo_titulo,
    sp.status               AS estado_modulo,
    sp.started_at,
    sp.completed_at,
    sp.attendance_count
FROM course_enrollments ce
JOIN tenants t          ON t.id = ce.tenant_id
JOIN student_progress sp ON sp.enrollment_id = ce.id
JOIN course_modules cm   ON cm.id = sp.module_id
WHERE t.slug = 'mia'
ORDER BY ce.id, sp.updated_at DESC;


-- ------------------------------------------------------------
-- 4. ZONA VERDE: cruce perfil Kolb (form_response) <-> avance
--    Esto es la JOYA pedagogica: muestra que SI se puede
--    cruzar perfil con progreso, sin gap.
-- ------------------------------------------------------------
SELECT
    ce.student_name,
    fr.computed_result->>'dominant_style' AS perfil_kolb,
    COUNT(sp.id) FILTER (WHERE sp.status = 'completed') AS modulos_completados,
    ce.status AS estado
FROM course_enrollments ce
JOIN tenants t          ON t.id = ce.tenant_id
LEFT JOIN form_responses fr
       ON fr.enrollment_id = ce.id
LEFT JOIN student_progress sp
       ON sp.enrollment_id = ce.id
WHERE t.slug = 'mia'
GROUP BY ce.id, fr.computed_result
ORDER BY modulos_completados DESC;


-- ------------------------------------------------------------
-- 5. ZONA AMARILLA: el "avance narrativo" vs el "avance numerico"
--    Aqui muestras la DECISION DE DISENO en vivo
-- ------------------------------------------------------------
SELECT
    ce.student_name,
    ci.comprehension_level         AS nivel_comprension_NARRATIVO,
    ci.emotional_state             AS estado_emocional,
    LEFT(ci.evolution_notes, 200)  AS evolution_notes_PRIMEROS_200_CHARS,
    ci.topics_covered              AS temas_cubiertos_JSON
FROM course_enrollments ce
JOIN tenants t              ON t.id = ce.tenant_id
LEFT JOIN conversation_insights ci ON ci.enrollment_id = ce.id
WHERE t.slug = 'mia'
ORDER BY ce.enrolled_at DESC;
-- ^^ Aqui PREGUNTAS al cliente: "Pero, donde esta el avance como NUMERO?"
-- Respuesta honesta: NO existe. Es decision de diseno: MIA cuenta historia, no calcula KPI.
-- Si quieren KPI numerico, hay que agregar columnas: progress_score (int), goal_completion (decimal), etc.


-- ------------------------------------------------------------
-- 6. ZONA AMARILLA #2: el "objetivo declarado" del coachee
--    Mostrar como onboarding_data es JSON libre, sin schema
-- ------------------------------------------------------------
SELECT
    ce.student_name,
    ce.enrolled_at,
    jsonb_pretty(ce.onboarding_data::jsonb) AS onboarding_data_RAW_JSON
FROM course_enrollments ce
JOIN tenants t ON t.id = ce.tenant_id
WHERE t.slug = 'mia'
  AND ce.onboarding_data IS NOT NULL
LIMIT 5;
-- ^^ Aqui senalas: "Ven? Cada coachee tiene un JSON libre. NO hay columna 'declared_objective'
-- ni tabla 'coachee_goals'. Si su pregunta es 'que objetivo declaro cada uno', la BD me obliga
-- a leer JSON sin schema. Eso es gap estructural — y es exactamente lo que un buen modelado
-- evitaria si la pregunta fuera importante para el negocio."


-- ------------------------------------------------------------
-- BACKUP: queries de exploracion por si necesitas en vivo
-- ------------------------------------------------------------

-- Conteo total de filas por tabla relevante (para dimensionar el dataset)
SELECT 'course_enrollments' AS tabla, COUNT(*) FROM course_enrollments ce JOIN tenants t ON t.id = ce.tenant_id WHERE t.slug = 'mia'
UNION ALL SELECT 'student_progress',   COUNT(*) FROM student_progress sp JOIN course_enrollments ce ON ce.id = sp.enrollment_id JOIN tenants t ON t.id = ce.tenant_id WHERE t.slug = 'mia'
UNION ALL SELECT 'conversation_insights', COUNT(*) FROM conversation_insights ci JOIN course_enrollments ce ON ce.id = ci.enrollment_id JOIN tenants t ON t.id = ce.tenant_id WHERE t.slug = 'mia'
UNION ALL SELECT 'form_responses',     COUNT(*) FROM form_responses fr JOIN course_enrollments ce ON ce.id = fr.enrollment_id JOIN tenants t ON t.id = ce.tenant_id WHERE t.slug = 'mia';
