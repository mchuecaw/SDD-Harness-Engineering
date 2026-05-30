# CHECKPOINTS — Evaluación del estado final

> En sistemas multi-agente no se evalúa el camino, se evalúa el destino.
> Estos son los checkpoints objetivos que un juez (humano o IA) puede usar
> para decidir si el proyecto está sano. El agente `reviewer` los recorre
> antes de aprobar el cierre de una feature.

## C1 — El arnés está completo

- [ ] Existen los archivos base: `AGENTS.md`, `CLAUDE.md`, `init.sh`,
      `feature_list.json`, `harness.config`, `progress/current.md`.
- [ ] Existen los docs: `docs/methodology.md`, `docs/harness-engineering.md`,
      `docs/specs.md`, `docs/architecture.md`, `docs/conventions.md`,
      `docs/verification.md`.
- [ ] `./init.sh` termina con exit code 0.

## C2 — El estado es coherente

- [ ] Como mucho una feature en `in_progress` en `feature_list.json`.
- [ ] Toda feature `done` tiene tests asociados que pasan.
- [ ] `progress/current.md` está vacío (plantilla) o describe la sesión activa
      (no contiene basura de sesiones anteriores).

## C3 — El código respeta la arquitectura

- [ ] `src/` solo contiene los módulos previstos en `docs/architecture.md`.
- [ ] No se han añadido dependencias externas sin justificación documentada
      (ver `docs/architecture.md`).
- [ ] No hay código muerto, prints de debug sueltos, ni TODOs sin contexto.

## C4 — La verificación es real

- [ ] `tests/` tiene al menos un test por unidad lógica de `src/`.
- [ ] Los tests ejercitan comportamiento real, no solo "no lanza excepción"
      (ver anti-patrones en `docs/verification.md`).
- [ ] El comando de tests (`TEST_CMD` en `harness.config`) muestra > 0 tests
      y todos en verde.

## C5 — La sesión se cerró bien

- [ ] No hay archivos sin trackear sospechosos (temporales, caches fuera del
      `.gitignore`).
- [ ] `progress/history.md` tiene una entrada por la última sesión.
- [ ] La última feature trabajada está reflejada en su estado correcto.

## C6 — Spec Driven Development

- [ ] Toda feature con `"sdd": true` en estado `spec_ready`, `in_progress`
      o `done` tiene su carpeta `specs/<name>/` con los 3 archivos:
      `requirements.md`, `design.md`, `tasks.md`.
- [ ] `requirements.md` usa EARS estricto (ver `docs/specs.md`).
- [ ] Toda feature `done` con `"sdd": true` tiene todas sus tasks marcadas
      `[x]` en `tasks.md`.
- [ ] Cada `R<n>` de `requirements.md` está cubierto por al menos un test
      concreto en `tests/`.
- [ ] La puerta de aprobación humana se respetó: ninguna feature pasó de
      `spec_ready` a `in_progress` sin aprobación.

---

**Cómo usar este archivo:** el agente `reviewer` (`.claude/agents/reviewer.md`)
recorre cada checkbox, marca `[x]` o `[ ]` en su informe
`progress/review_<feature>.md`, y rechaza el cierre de la feature si quedan
boxes vacíos en C1-C6.
