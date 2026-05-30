# Harness Engineering — Los pilares y el patrón de orquestación

> Este documento describe el **sistema** dentro del que trabaja el agente.
> Para ver cómo se conecta con SDD, lee [`methodology.md`](methodology.md).

## Idea central

Un "arnés" (*harness*) es el conjunto de archivos, convenciones y mecanismos
de verificación que convierten un repositorio en un entorno donde un agente de
IA puede trabajar **de forma autónoma, supervisada y reproducible**. El valor
no está en el código de la app, sino en cómo está estructurado el repo
alrededor.

## Pilar 1 — El repositorio ES el sistema

Nada vive solo en la cabeza del agente ni en el historial de chat. Todo está
en archivos versionados:

| Necesidad del agente | Archivo del arnés |
|----------------------|-------------------|
| ¿Por dónde empiezo?  | `AGENTS.md` (mapa de navegación, divulgación progresiva) |
| ¿Qué hay que hacer y en qué estado está? | `feature_list.json` |
| ¿Qué es "buen trabajo"? | `docs/architecture.md`, `docs/conventions.md` |
| ¿Cómo demuestro que funciona? | `docs/verification.md`, `init.sh` |
| ¿En qué iba la última sesión? | `progress/current.md`, `progress/history.md` |
| ¿Cómo sé que el estado final es correcto? | `CHECKPOINTS.md` |

**Divulgación progresiva:** `AGENTS.md` no vuelca todas las reglas de golpe; es
un mapa que el agente consulta bajo demanda. Esto mantiene el contexto ligero
y la atención donde toca.

## Pilar 2 — Orquestación multi-agente

Un único agente que lo hace todo se autoengaña: implementa y se aprueba a sí
mismo. El arnés separa responsabilidades en agentes con permisos distintos
(ver `.claude/agents/`):

```text
                  ┌─► explorer ∥   (solo lectura: investiga)
   orquestador ───┼─► spec_author  (escribe specs, no código)
   (orquesta,     ├─► implementer  (escribe código + tests)
   no implementa) └─► reviewer     (aprueba/rechaza, no edita)
```

Reglas de separación de poderes:

- El **orquestador** no implementa (no toca `src/` ni `tests/`).
- El **spec_author** no codifica (solo `specs/`).
- El **implementer** no se autoaprueba (no marca `done` solo).
- El **reviewer** no edita código (solo dice qué falla).

### El patrón de exploración paralela

Cuando una tarea necesita entender el código antes de actuar, el orquestador lanza
**2-3 `explorer` en paralelo**, cada uno con una pregunta acotada. Cada uno
escribe `progress/explore_<tema>.md`. Esto cubre más terreno en menos tiempo y
mantiene cada investigación enfocada.

## Pilar 3 — Estado en disco (regla anti-teléfono-descompuesto)

Los subagentes **escriben sus resultados en archivos** y devuelven al orquestador
solo una referencia ligera:

```
done -> progress/impl_<feature>.md
spec_ready -> specs/<feature>/
done -> progress/explore_<tema>.md
```

Por qué importa:

- **El contenido no se degrada** al pasar por el chat (de ahí el nombre).
- **El trabajo es auditable**: abres `progress/` y `specs/` en tu editor y ves
  exactamente quién decidió qué.
- **Sobrevive a reinicios** y a context windows agotadas: el estado está en
  disco y versionado, no en la memoria de la sesión.

## Pilar 4 — Supervisión ejecutable

El arnés no se fía de que el agente diga "funciona". Lo verifica:

- **`init.sh`** — valida la estructura del arnés, los invariantes de
  `feature_list.json` (máximo 1 `in_progress`, specs presentes para features
  `sdd`) y ejecuta la suite de tests (`TEST_CMD` de `harness.config`).
- **Hooks** (`.claude/settings.json`) — el harness los ejecuta, no el agente,
  así que **no se pueden saltar**. Tras cada `Edit`/`Write` corre los tests;
  al cerrar la sesión (`Stop`) fuerza un `init.sh` completo.
- **`CHECKPOINTS.md`** — criterios objetivos de "estado final correcto" que el
  reviewer recorre antes de aprobar.

> En sistemas multi-agente **no se evalúa el camino, se evalúa el destino**.
> Los checkpoints son ese destino, hecho explícito.

## Cómo adaptarlo a tu stack

El arnés es agnóstico de lenguaje. Lo único específico de tu stack es:

1. `harness.config` → `TEST_CMD` (cómo se ejecutan tus tests).
2. `docs/architecture.md` y `docs/conventions.md` → tu arquitectura y estilo.
3. `feature_list.json` → tus features.

El resto (agentes, flujo, verificación, checkpoints) funciona igual en
Python, TypeScript, Go, Rust o lo que uses.
