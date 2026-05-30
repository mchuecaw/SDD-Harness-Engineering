# SDD-Harness — Template que une Spec Driven Development y Harness Engineering

Este repositorio es un **template reutilizable y agnóstico de lenguaje** para
arrancar proyectos en los que un agente de IA (Claude Code u otro) trabaja de
forma **autónoma, supervisada y verificable**.

No contiene una aplicación: contiene el **arnés** (la metodología hecha
archivos). Clónalo, vacíalo de los placeholders y tienes un proyecto listo
para que un agente lo desarrolle bajo control.

> **La idea en una frase:** *Harness Engineering* es el **sistema** dentro del
> que trabaja el agente; *Spec Driven Development* es el **proceso** que
> gobierna cómo nace cada feature dentro de ese sistema. Este template los
> fusiona en un único flujo.

---

## Las dos mitades que une este template

| Mitad | Qué aporta | Dónde vive |
|-------|------------|------------|
| **Harness Engineering** | El repo *es* el sistema; orquestación multi-agente (`orquestador → explorers ∥ → implementer → reviewer`); estado en disco; supervisión ejecutable. | `AGENTS.md`, `init.sh`, `feature_list.json`, `progress/`, `CHECKPOINTS.md`, `.claude/` |
| **Spec Driven Development** | Toda feature pasa por `requirements (EARS) → design → tasks → code`, con una **puerta de aprobación humana** y **trazabilidad** requisito↔test. | `docs/specs.md`, `specs/<feature>/`, agente `spec_author`, gate `spec_ready` |

La explicación completa de cómo encajan está en
[`docs/methodology.md`](docs/methodology.md). Léela primero.

---

## El flujo unificado

```text
         ┌───────────────────────── HARNESS ENGINEERING (el sistema) ─────────────────────────┐
tarea ─► orquestador ─► explorers ─► spec_author ─► [HUMANO] ─► implementer ─► reviewer ─► done
                                     └───────────────────── SDD ──────────────────────┘
```

- **Harness Engineering** = todo el pipeline (orquestación, estado en disco,
  verificación). El `orquestador` lo gobierna; `explorers` reúnen contexto.
- **SDD** = el tramo `spec_author → [HUMANO] aprueba → implementer (por tasks) →
  reviewer`, que define *qué* se construye y *cómo* se prueba cada feature.

---

## Cómo usar este template

1. **Clónalo / úsalo como template** y renómbralo a tu proyecto.
2. Edita los placeholders marcados con `REEMPLAZA`:
   - `feature_list.json` → tu proyecto y tus features reales.
   - `harness.config` → el comando de tests de tu stack (`TEST_CMD`).
   - `docs/architecture.md` y `docs/conventions.md` → tu arquitectura y estilo.
3. Ejecuta `./init.sh`. Debe terminar en verde (al principio avisará de que
   `TEST_CMD` no está configurado — es normal hasta que tengas tests).
4. Abre Claude Code en la raíz. `CLAUDE.md` ya fuerza al modelo a actuar como
   `orquestador` y a seguir el flujo SDD.
5. Pídele: **«implementa la siguiente feature pendiente»** y observa
   `specs/` y `progress/` en tu editor mientras trabaja.

Walkthrough narrado de una feature completa (sin código real, solo el flujo):
[`docs/example-walkthrough.md`](docs/example-walkthrough.md).

---

## Estructura

```
.
├── README.md              # Este archivo
├── CLAUDE.md              # Carga automática: fuerza el rol orquestador + flujo SDD
├── AGENTS.md              # Mapa de navegación para agentes (divulgación progresiva)
├── CHECKPOINTS.md         # Criterios objetivos de "estado final correcto"
├── feature_list.json      # Alcance: una feature a la vez, con estados
├── init.sh                # Verificación e inicialización del arnés
├── harness.config         # Config del template (TEST_CMD de tu stack)
├── docs/
│   ├── methodology.md         # ★ Cómo SDD y Harness Engineering encajan
│   ├── harness-engineering.md # Los pilares y el patrón de orquestación
│   ├── specs.md               # Proceso SDD: EARS, 3 archivos, gate, trazabilidad
│   ├── example-walkthrough.md # Una feature de principio a fin (narrado)
│   ├── architecture.md        # TEMPLATE: tu arquitectura
│   ├── conventions.md         # TEMPLATE: tu estilo y convenciones
│   └── verification.md        # Cómo demostrar que el trabajo funciona
├── specs/
│   └── _template/         # Plantilla de los 3 archivos de spec
│       ├── requirements.md
│       ├── design.md
│       └── tasks.md
├── progress/
│   ├── current.md         # Sesión activa (estado vivo)
│   └── history.md         # Bitácora append-only
├── .claude/
│   ├── agents/            # orquestador, explorer, spec_author, implementer, reviewer
│   └── settings.json      # Hooks que automatizan la verificación
├── src/                   # Tu código (vacío en el template)
└── tests/                 # Tus tests (vacío en el template)
```

---

## Origen

Este template fusiona y generaliza dos proyectos didácticos de
[betta-tech](https://github.com/betta-tech):

- [`ejemplo-harness-subagentes`](https://github.com/betta-tech/ejemplo-harness-subagentes)
  — Harness Engineering (orquestación multi-agente).
- [`harness-sdd`](https://github.com/betta-tech/harness-sdd)
  — la capa Spec Driven Development encima del arnés.

Ambos usaban un CLI de notas en Python como ejemplo. Este template extrae la
**metodología** y la deja lista para cualquier stack.
