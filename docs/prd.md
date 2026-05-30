# PRD -- Product Requirements Document

> El PRD es el artefacto del "que" y el "porque" a alto nivel. Es la fuente de
> la que cuelga todo: cada Epic se descompone en User Stories, y cada User Story
> se vuelve una feature `"sdd": true` en `feature_list.json` con su propio spec.
> Plantilla en `templates/prd.md`. Para ver como encaja en el flujo, lee
> `docs/methodology.md`.

## Que captura un PRD (en orden de importancia)

1. **Business problem to solve** -- el problema de negocio/usuario que duele hoy,
   con evidencia, sin proponer todavia la solucion.
2. **Business Case / Impact** -- la seccion mas importante. Por que ahora, coste
   de no hacerlo, e impacto esperado en una metrica de negocio (ingresos,
   retencion, attach rate, coste evitado, NPS), aunque sea un orden de magnitud.
   Un PRD sin business case es una lista de deseos.
3. **Objetivos y metricas de exito** -- KPIs medibles con linea base y meta.
4. **Usuarios objetivo** -- 1-3 personas con su job-to-be-done.
5. **Scope** -- lo que el MVP hace y, explicito, lo que NO hace.
6. **Epics con Use Cases** -- el cuerpo del PRD.
7. Assumptions, dependencies, risks, non-goals, open questions.

## Jerarquia: PRD -> Epic -> Use Case -> User Story

- **Epic**: una capacidad coherente con un outcome de negocio, con prioridad
  (must/should/could) y un conjunto de Use Cases.
- **Use Case**: a nivel conversacional, `Como <actor>, quiero <objetivo> para
  <valor>`. Todavia NO es Gherkin ni tiene criterios de aceptacion formales.
- **User Story**: la unidad ejecutable. Aterriza en `feature_list.json` como una
  feature `"sdd": true` con `acceptance` concretos (que el `spec_author`
  convierte en `R<n>` EARS). Debe ser pequena: cabe en un spec y se construye en
  una sesion.

Trazabilidad del "que":
**PRD -> Epic -> Use Case -> User Story -> feature_list.json -> specs/<us>/**.

## Limite de detalle (nivel MVP) -- IMPORTANTE

El error mas comun es meter demasiado detalle en el PRD. La regla:

> El PRD se detiene a nivel **Epic + Use Case**. No baja a User Stories, ni a
> criterios de aceptacion EARS, ni a diseno tecnico.

Un PRD de MVP, en concreto:

- Tiene del orden de **3 a 8 Epics**, cada uno con **2 a 6 Use Cases**.
- Cabe en **2 a 5 paginas**. Si crece mas, esta entrando en territorio de spec
  o de ADR.
- **NO** enumera todas las User Stories (se derivan despues, al refinar).
- **NO** contiene criterios de aceptacion EARS (`R<n>`) -- eso es
  `specs/<us>/requirements.md`.
- **NO** contiene diseno tecnico, firmas, esquemas ni contratos de API -- eso es
  `design.md` y los ADRs.
- **NO** contiene mockups de UI detallados; como mucho, bocetos de bajo nivel.

Frontera mental:

| Artefacto                  | Responde a                                  |
|----------------------------|---------------------------------------------|
| PRD (Epic + Use Case)      | que problema y que capacidades              |
| spec/requirements.md (EARS)| que tiene que cumplir exactamente esta US   |
| ADR                        | que decidimos tecnicamente (y por que)      |
| spec/design.md             | como se construye esta US                   |

## El backlog SCRUM en feature_list.json

Este repo es **SCRUM-based**: el `feature_list.json` es el product backlog. Las
Epics y las User Stories viven ahi de forma trazable y verificable:

- Bloque `epics`: una entrada por Epic (`id` tipo `E1`, `title`, `priority`,
  `outcome`).
- Cada feature es una **User Story** con estos campos SCRUM:
  - `us_id` -- id estable de la US (`US-001`). Unico en el archivo.
  - `epic` -- el `id` del Epic al que pertenece (debe estar declarado en `epics`).
  - `story_points` -- estimacion (entero positivo; p. ej. escala Fibonacci).
  - `priority` -- `must | should | could | wont` (MoSCoW).
  - `sprint` -- sprint asignado (o `null` si esta en backlog sin planificar).
  - `name`, `title`, `description`, `acceptance`, `sdd`, `status` (como ya
    existian).

Regla dura (la verifica `init.sh` y el checkpoint C9): **toda feature
`"sdd": true` es una User Story y DEBE tener `us_id` y `epic` declarado**; los
`us_id` son unicos. Una feature ad-hoc (sin US de respaldo) usa `"sdd": false` y
no requiere `us_id`/`epic`.

## Donde vive

- La plantilla del PRD: `templates/prd.md`.
- El backlog (epics + user stories): `feature_list.json`.
- El PRD real de tu proyecto: donde tu equipo lo gestione (este template no
  impone una ruta unica; lo natural es `docs/prd/<producto>.md` o un sistema de
  producto externo). Lo que SI vive en el repo es la trazabilidad Epic -> US a
  traves de `feature_list.json`.
- Un ejemplo completo (contexto Wallbox, ilustrativo): `examples/prd-eco-smart.md`.
