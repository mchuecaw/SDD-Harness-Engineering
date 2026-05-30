# Walkthrough — Una feature de principio a fin

> Este documento narra el flujo completo SDD + Harness para **una** feature,
> sin código real, para que veas qué pasa y dónde queda cada artefacto. Úsalo
> como guion mental cuando le pidas al agente «implementa la siguiente feature
> pendiente».

Supongamos una feature `pending` con `"sdd": true` en `feature_list.json`,
llamada `exportar_informe`.

---

## 0. Arranque

Abres Claude Code en la raíz. `CLAUDE.md` lo pone en rol **leader**. Le dices:

> «implementa la siguiente feature pendiente»

El leader lee `AGENTS.md`, `feature_list.json` y `progress/current.md`, y
ejecuta `./init.sh`. Verde → continúa.

## 1. (Opcional) Exploración paralela

Si la feature toca código que el leader no conoce, lanza 2-3 `explorer` en
paralelo, p. ej.:

- «¿cómo se serializan los datos hoy?» → `progress/explore_serializacion.md`
- «¿qué interfaz expone la capa actual?» → `progress/explore_interfaz.md`

Cada explorer devuelve solo `done -> progress/explore_<tema>.md`. El contenido
vive en disco.

## 2. Fase Spec (SDD)

El leader lanza **1 `spec_author`**. Este escribe tres archivos en
`specs/exportar_informe/`:

- `requirements.md` — los `R1..Rn` en EARS, más la tabla de trazabilidad
  contra el `acceptance` original.
- `design.md` — archivos a tocar, firmas nuevas, errores, y una alternativa
  descartada.
- `tasks.md` — `T1..Tn`, cada una citando los `R<n>` que cubre.

Cambia el estado de la feature a `spec_ready` y **para**. Su respuesta al
leader es una línea: `spec_ready -> specs/exportar_informe/`.

El leader te dice:

> «Spec listo en `specs/exportar_informe/`. Revísalo y di **'aprobado'** o
> pídeme cambios.»

## 3. ⏸ Puerta de aprobación humana (tu turno)

Abres los tres archivos en tu editor. Este es tu punto de control:

- ¿`requirements.md` captura lo que de verdad quieres? ¿Falta algún caso de
  error? ¿Sobra alcance?
- ¿`design.md` toma decisiones razonables? ¿La alternativa descartada tiene
  sentido?
- ¿`tasks.md` es un plan ejecutable y completo?

Si algo no cuadra, pides cambios y el `spec_author` reescribe. Cuando estás
conforme, dices **«aprobado»**.

> Corregir aquí cuesta minutos. Corregir código equivocado, horas. Por eso esta
> puerta existe.

## 4. Fase Código (SDD dentro del arnés)

Tras tu aprobación, el leader cambia el estado a `in_progress` y lanza **1
`implementer`**. Este:

1. Lee el spec completo.
2. Ejecuta `tasks.md` una a una, marcando `[x]` cada `T<n>`.
3. Escribe el test de cada cambio antes de pasar a la siguiente task.
4. Tras cada `Edit`/`Write`, el **hook** corre los tests automáticamente.
5. Documenta la trazabilidad `R<n> → test` en `progress/impl_exportar_informe.md`.
6. Devuelve `done -> progress/impl_exportar_informe.md`.

## 5. Revisión

El leader lanza **1 `reviewer`**, que:

- Verifica que **cada `R<n>` tiene un test** que lo cubre.
- Verifica que **todas las tasks están `[x]`**.
- Comprueba arquitectura y convenciones.
- Ejecuta `./init.sh` (verde) y recorre `CHECKPOINTS.md`.
- Escribe el veredicto en `progress/review_exportar_informe.md` y devuelve
  `APPROVED -> ...` o `CHANGES_REQUESTED -> ...`.

Si pide cambios, el leader relanza al `implementer` con el feedback y se repite
la revisión.

## 6. Cierre

Con el reviewer en `APPROVED`, el implementer marca la feature como `done`,
mueve el resumen de `progress/current.md` a `progress/history.md`, y deja
`current.md` en su plantilla vacía. El hook `Stop` fuerza un último `init.sh`.

---

## Mapa de quién escribe qué

| Archivo                                  | Quién lo escribe   | Qué contiene |
|------------------------------------------|--------------------|--------------|
| `progress/explore_<tema>.md`             | explorer           | Hallazgos de una investigación acotada |
| `specs/<feature>/requirements.md`        | spec_author        | EARS `R1`, `R2`, ... + trazabilidad |
| `specs/<feature>/design.md`              | spec_author        | Decisiones técnicas + alternativa descartada |
| `specs/<feature>/tasks.md`               | spec_author / implementer | Checklist `T<n>`; el implementer la marca `[x]` |
| `progress/current.md`                    | leader / implementer | Plan vivo de la sesión |
| `progress/impl_<feature>.md`             | implementer        | Archivos tocados + mapa `R<n> → test` + output de tests |
| `progress/review_<feature>.md`           | reviewer           | Veredicto + checkpoints |
| `feature_list.json`                      | leader / implementer | `pending → spec_ready → in_progress → done` |
| `progress/history.md`                    | leader / implementer | Resumen append-only al cerrar |

Abre `specs/` y `progress/` en tu editor mientras el agente trabaja: cada
informe aparece en cuanto el subagente termina. Eso es la regla
anti-teléfono-descompuesto en acción.
