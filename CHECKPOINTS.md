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
- [ ] Existen los artefactos de gobernanza: `docs/prd.md`, `docs/adr.md`,
      `docs/skills.md`, `docs/adr/README.md`, `docs/adr/_template.md`,
      `templates/prd.md`, `skills/registry.json`.
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

## C7 — Gobernanza de Skills

- [ ] Todo directorio en `.claude/skills/` tiene una entrada `published` en
      `skills/registry.json`.
- [ ] Ningún skill `proposed`/`review` está físicamente en `.claude/skills/`
      (solo en `skills/_staging/`).
- [ ] Todo skill `published` tiene `approved_by` (humano) y `version`.
- [ ] Todo skill tiene `proposal.md` con casos de evaluación (triggers,
      anti-triggers, golden case).

## C8 — Gobernanza de ADRs

- [ ] Todo ADR `accepted` tiene `Status`, `Scope` y >= 1 alternativa.
- [ ] No hay dos ADR `accepted` que se contradigan en el mismo `Scope` sin un
      link de supersede.
- [ ] Cada decisión técnica de un `design.md` traza a un ADR `accepted` o a
      `docs/architecture.md`.
- [ ] Los ADR `superseded` no se han borrado.

## C9 — Trazabilidad SCRUM (PRD → Epic → User Story)

- [ ] Toda feature `"sdd": true` (= User Story) tiene `us_id` y `epic`.
- [ ] Todo `epic` referenciado por una feature está declarado en el bloque
      `epics` de `feature_list.json`.
- [ ] Los `us_id` son únicos en `feature_list.json`.
- [ ] `priority` (si está) es uno de `valid_priority`; `story_points` (si está)
      es un entero positivo.
- [ ] Cada User Story es trazable a un Use Case de un Epic del PRD
      (PRD → Epic → Use Case → User Story → `feature_list.json`).

---

**Cómo usar este archivo:** el agente `reviewer` (`.claude/agents/reviewer.md`)
recorre cada checkbox, marca `[x]` o `[ ]` en su informe
`progress/review_<feature>.md`, y rechaza el cierre de la feature si quedan
boxes vacíos en C1-C9.
