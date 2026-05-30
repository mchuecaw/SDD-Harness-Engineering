# Metodología — Cómo encajan SDD y Harness Engineering

> Este es el documento que da sentido a todo el repositorio. Léelo entero una
> vez; el resto de archivos son los detalles operativos de lo que aquí se
> explica.

## El problema que resuelve

Un agente de IA potente, suelto en un repositorio, falla por dos razones
distintas:

1. **Falta de sistema.** No sabe dónde está el estado, qué es "buen trabajo",
   cómo verificar, ni cómo coordinarse consigo mismo a lo largo de sesiones.
   → Lo resuelve **Harness Engineering**.
2. **Falta de proceso.** Salta directo a escribir código sin acordar primero
   *qué* hay que construir y *cómo se demostrará* que está bien, así que
   produce algo plausible pero equivocado.
   → Lo resuelve **Spec Driven Development**.

Las dos cosas son ortogonales y complementarias. Este template las une.

## Las dos capas

### Harness Engineering = el sistema (el "dónde" y el "cómo se coordina")

El **arnés** es el repositorio convertido en un entorno de trabajo para
agentes. Sus pilares:

1. **El repositorio ES el sistema.** Todo lo que el agente necesita saber está
   en archivos versionados, no en la cabeza de nadie ni en el chat:
   `AGENTS.md` (mapa), `feature_list.json` (alcance), `docs/` (estándar de
   calidad), `progress/` (estado vivo), `init.sh` (verificación).
2. **Orquestación multi-agente.** Un `leader` descompone y coordina; agentes
   especializados (`explorer`, `spec_author`, `implementer`, `reviewer`)
   hacen el trabajo. Nadie se autoaprueba.
3. **Estado en disco, no en chat.** Los subagentes escriben sus resultados en
   archivos y solo devuelven una referencia ligera (regla
   *anti-teléfono-descompuesto*). El trabajo sobrevive a reinicios y a
   ventanas de contexto reventadas.
4. **Supervisión ejecutable.** `init.sh`, los hooks de `.claude/settings.json`
   y `CHECKPOINTS.md` verifican el *destino*, no se fían del *camino*.

Detalle completo en [`harness-engineering.md`](harness-engineering.md).

### Spec Driven Development = el proceso (el "qué" y el "cómo se prueba")

**SDD** es el ciclo de vida obligatorio de cada feature dentro del arnés:

```
requirements (EARS)  →  design  →  tasks  →  code
        │                                       │
        └────────── trazabilidad R<n> ↔ test ───┘
```

con una **puerta de aprobación humana** justo después de la fase de spec: el
agente no escribe código hasta que un humano ha leído y aprobado el spec.

Detalle completo en [`specs.md`](specs.md).

## Cómo se conectan: SDD vive *dentro* del arnés

La forma más simple de entenderlo: **Harness Engineering es el contenedor;
SDD es lo que ocurre dentro de una de sus fases.**

```
        ┌──────────────── HARNESS ENGINEERING (el sistema) ─────────────────┐
        │   repo-como-sistema · orquestación multi-agente · supervisión      │
        │                                                                    │
 tarea ─┼─► leader ─► explorers ∥ ─► spec_author ─► ⏸ HUMANO ─► implementer ─► reviewer ─┼─► done
        │     │            │             │ (SDD)      gate         │ (SDD)        │      │
        │  current.md  explore_*.md  specs/<f>/                 src/+tests/  CHECKPOINTS│
        └─────────────────────────────────────────────────────────────────────────────┘
                                    └──────────── SDD ─────────────┘
```

Cada agente del arnés tiene un papel en el ciclo SDD:

| Agente (Harness) | Su responsabilidad en SDD |
|------------------|----------------------------|
| `leader`         | Gobierna las transiciones de estado y **detiene el flujo en la puerta de aprobación humana**. |
| `explorer`       | Reúne el contexto que el `spec_author` necesita para escribir requirements correctas. |
| `spec_author`    | Produce los 3 artefactos SDD (`requirements`/`design`/`tasks`) y para en `spec_ready`. |
| `implementer`    | Ejecuta las `tasks` y garantiza la **trazabilidad** `R<n> → test`. |
| `reviewer`       | Verifica que SDD se respetó: cobertura de cada `R<n>`, tasks completas, checkpoints. |

Y cada estado de `feature_list.json` es un punto del ciclo SDD que el arnés
hace observable y verificable:

| Estado        | Fase SDD                     | Garantía del arnés |
|---------------|------------------------------|--------------------|
| `pending`     | Sin spec                     | El `spec_author` es el primero en actuar. |
| `spec_ready`  | Spec redactado, sin aprobar  | `init.sh` exige que existan los 3 archivos; el `leader` para. |
| `in_progress` | Spec aprobado, codificando   | Como mucho 1 feature aquí a la vez (`init.sh` lo valida). |
| `done`        | Verificado y revisado        | Tests verdes + reviewer aprobó + checkpoints. |
| `blocked`     | Atascado                     | Razón documentada en `progress/`. |

## Por qué la unión es más que la suma

- **SDD sin arnés** se queda en buenas intenciones: nadie obliga a que el spec
  exista, ni a que cada requisito tenga un test. → El arnés lo hace ejecutable
  (`init.sh` rechaza una feature `sdd` sin sus 3 archivos; el `reviewer`
  rechaza un `R<n>` sin test).
- **Arnés sin SDD** orquesta agentes muy rápido hacia el objetivo equivocado:
  el `implementer` parte de criterios de aceptación ambiguos. → SDD le da una
  diana precisa (requirements EARS) y una puerta donde el humano corrige el
  rumbo *antes* de que se gaste esfuerzo en código.

## Qué tienes que hacer tú (el humano)

Tu trabajo en este sistema es pequeño pero decisivo: **leer el spec en la
puerta de aprobación**. Ese es el punto de máximo apalancamiento — corregir un
`requirements.md` cuesta minutos; corregir código equivocado cuesta horas.

Todo lo demás (descomponer, explorar, especificar, implementar, verificar) lo
hace el arnés.

## Cuándo NO aplica SDD

Features marcadas `"sdd": false` (o sin el campo) saltan la fase de spec: el
`leader` puede lanzar directamente al `implementer`. Útil para cambios
triviales o legacy. SDD se aplica **hacia adelante**, no se reescribe el
pasado.
