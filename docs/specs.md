# Spec Driven Development (SDD)

> Flujo: requirements → design → tasks → code. El código no se escribe hasta
> que el spec está aprobado por un humano. Para ver cómo SDD encaja en el
> arnés, lee [`methodology.md`](methodology.md).

## Estructura

Cada feature nueva (`"sdd": true` en `feature_list.json`) tiene una carpeta
dedicada en cuanto deja `pending`:

```
specs/<feature-name>/
├── requirements.md   # QUÉ se necesita (EARS notation)
├── design.md         # CÓMO se construirá (decisiones técnicas)
└── tasks.md          # PASOS concretos a implementar
```

El `feature-name` coincide con el campo `name` de `feature_list.json`. Hay
plantillas listas para copiar en `specs/_template/`.

## Estados de una feature

| Estado         | Significado                                                    |
|----------------|----------------------------------------------------------------|
| `pending`      | Sin spec. El `spec_author` es el primero en actuar.            |
| `spec_ready`   | Spec drafted. Esperando aprobación humana. NO se toca código.  |
| `in_progress`  | Spec aprobado. `implementer` trabajando.                       |
| `done`         | Código verde, `reviewer` aprobó, sesión cerrada.               |
| `blocked`      | Atascado. Razón en `progress/current.md`.                      |

## La puerta de aprobación humana

El flujo automático se detiene **una vez**: cuando el `spec_author` termina
sus tres archivos, marca la feature como `spec_ready` y para. El humano lee
`specs/<feature>/` y dice "aprobado" (o pide cambios).

Solo entonces el `orquestador` transiciona `spec_ready → in_progress` y lanza el
`implementer`.

```
pending → [spec_author] → spec_ready → ⏸ HUMANO → in_progress → [implementer → reviewer] → done
```

Esta puerta es el punto de máximo apalancamiento del humano: corregir un
requisito cuesta minutos; corregir código equivocado, horas.

## requirements.md — EARS estricto

Las requirements se redactan en **EARS** (Easy Approach to Requirements
Syntax). Cada requirement es un párrafo numerado con uno de estos cinco
patrones:

| Patrón         | Plantilla                                                   |
|----------------|-------------------------------------------------------------|
| **Ubicuo**     | `El sistema DEBE <acción>.`                                 |
| **Evento**     | `CUANDO <disparador>, el sistema DEBE <acción>.`            |
| **Estado**     | `MIENTRAS <estado>, el sistema DEBE <acción>.`              |
| **Opcional**   | `DONDE <feature opcional>, el sistema DEBE <acción>.`       |
| **No deseado** | `SI <evento no deseado> ENTONCES el sistema DEBE <acción>.` |

Reglas duras:

- Cada requirement tiene un id estable: `R1`, `R2`, ...
- Cada requirement DEBE ser verificable por al menos un test concreto.
- No mezcles varios `DEBE` en un mismo requirement. Si hay más de uno, parte.
- No uses verbos blandos ("podría", "puede", "soporta"). Solo `DEBE` / `NO DEBE`.

Ejemplo (genérico — adáptalo a tu dominio):

```markdown
## R1
CUANDO el usuario solicita el recurso `X` con un identificador válido,
el sistema DEBE devolver el recurso con código de éxito.

## R2
SI el identificador solicitado no existe ENTONCES el sistema DEBE responder
con un error explícito y un código distinto de éxito.
```

Incluye al final una **tabla de trazabilidad** que mapea cada criterio del
`acceptance` de `feature_list.json` a los `R<n>` que lo cubren.

## design.md — decisiones técnicas

Captura **antes** de tocar código:

- Qué archivos se crean / modifican.
- Qué firmas nuevas aparecen (funciones, clases, endpoints, comandos).
- Qué errores/excepciones se reutilizan o se añaden.
- Qué alternativa se descartó y por qué (mínimo una).

NO es ingeniería desde primeros principios — apóyate en
`docs/architecture.md` y `docs/conventions.md`. El `design.md` documenta los
puntos donde tu feature roza la frontera de esas reglas.

## tasks.md — checklist ejecutable

Pasos discretos en orden, cada uno con checkbox. Cada task referencia al
menos un `R<n>` que cubre.

```markdown
- [ ] T1 — <cambio en código>. Cubre: R1, R3.
- [ ] T2 — <registro / wiring>. Cubre: R1, R2.
- [ ] T3 — <test para el camino feliz>. Cubre: R1.
- [ ] T4 — <test para el camino de error>. Cubre: R2.
```

El `implementer` marca `[x]` cada task al completarla. El `reviewer` rechaza
si queda alguna `[ ]` sin justificación documentada.

## Trazabilidad (regla dura)

- Cada test en `tests/` debe poder mapearse a un `R<n>` de su spec.
- Cada `R<n>` debe tener al menos un test concreto.
- El `reviewer` comprueba esta correspondencia explícitamente y rechaza si
  falta.

El `implementer` documenta el mapa en `progress/impl_<name>.md`:

```markdown
## Trazabilidad
- R1 → `test_recurso_existente`
- R2 → `test_recurso_inexistente`
```

## Cuándo NO aplica SDD

Las features con `"sdd": false` o sin el campo `sdd` NO tienen spec: el
`orquestador` puede lanzar directamente al `implementer`. SDD solo se aplica hacia
adelante.
