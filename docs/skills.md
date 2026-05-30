# Skills -- gobernanza global

> Un skill es una capacidad o procedimiento reutilizable que un agente ejecuta:
> boilerplate, scaffolding, una validacion estandarizada, una transformacion. A
> diferencia de un ADR (que registra una decision), un skill *hace* algo, muchas
> veces. Registro en `skills/registry.json`; propuestas en `skills/_staging/`;
> publicados en `.claude/skills/`.

## Por que su puerta es la mas estricta

Un skill es transversal: se inyecta en el comportamiento de **todos los agentes,
en todas las sesiones y stacks**. Un skill malo no rompe una feature: envenena la
metodologia. Por eso su radio de impacto es el mayor de los tres artefactos
(feature < ADR < skill) y su puerta es la mas estricta: **doble llave humana**,
versionado y supersede-no-overwrite.

## Maquina de estados

```
proposed -> review -> approved -> published     (+ rejected, deprecated)
```

- `proposed` / `review`: vive en `skills/_staging/<skill>/`. **NO** esta en el
  path activo (`.claude/skills/`), asi que fisicamente no puede afectar a ningun
  agente. La puerta la impone el sistema de archivos, igual que con los specs.
- `approved`: el `skill_reviewer` dio APPROVED y el humano firmo.
- `published`: el `orquestador` lo movio a `.claude/skills/<skill>/` y registro
  la entrada en `skills/registry.json`.

## Anatomia de una propuesta

Dos archivos en `skills/_staging/<skill-name>/`:

- `SKILL.md` -- el skill (frontmatter + cuando usar / cuando NO / procedimiento /
  ejemplos / convenciones que asume). Plantilla en la seccion de plantillas de
  abajo.
- `proposal.md` -- rationale, scope, risk_class y casos de evaluacion.

Y una entrada en `skills/registry.json` con: `name`, `version`, `status`,
`risk_class`, `scope`, `proposed_by`, `reviewed_by`, `approved_by`, `date`,
`supersedes`. **El registry es la fuente de verdad** del estado de cada skill
(el frontmatter de `SKILL.md` es informativo; Claude Code solo interpreta
`name`, `description` y `allowed-tools`).

## Agentes y puerta

- `skill_author` -- redacta `SKILL.md` + `proposal.md` en staging. No publica.
- `skill_reviewer` -- valida: triggers (dispara cuando debe y NO cuando no debe),
  convenciones, solape con skills existentes, riesgo no documentado. Emite
  APPROVED / CHANGES_REQUESTED. No publica.
- **Puerta humana (doble llave):** el `orquestador` promociona staging ->
  `.claude/skills/` solo cuando hay `skill_reviewer: APPROVED` Y aprobacion
  humana explicita. **Nada entra en el path activo sin firma humana.**

Dos refuerzos sobre la puerta de SDD:

- **Clase de riesgo.** `risk_class: safe | elevated`. Un skill `elevated`
  (concede tools nuevas, toca seguridad, deploy, dinero o borrados) exige un
  approver humano nominado y, opcionalmente, un segundo revisor.
- **Supersede-no-overwrite.** Cambiar un skill aprobado se hace subiendo una
  version nueva que vuelve a pasar la puerta, no editandolo en sitio. La
  provenance queda en el registry.

## Disparador y efecto

- **Disparador:** la recurrencia. Un skill se justifica cuando la misma forma se
  ha repetido en dos o tres US. Puede aflorar desde cualquier fase.
- **Efecto:** global. Una vez `published`, lo consumen todos los agentes. Se
  descubre a nivel US pero vive por encima de todo el sistema.

## ADR vs Skill -- como decidir

Cinco preguntas litmus:

1. Registra una DECISION (con alternativas y consecuencias) o automatiza una
   TAREA repetible? Decision -> ADR. Tarea -> Skill.
2. RESTRINGE lo que se puede construir, o ACELERA como se construye?
   Restringe -> ADR. Acelera -> Skill.
3. Si manana cambia, reescribes una decision (ADR nuevo que supera al anterior)
   o actualizas un procedimiento (version nueva del skill)?
4. Tiene sentido la pregunta "que alternativas se consideraron"? Si -> ADR. Un
   skill no considera alternativas, ejecuta un procedimiento.
5. Lo lees una vez para entender el porque (ADR) o lo invocas muchas veces para
   hacer algo (Skill)?

**Relacion complementaria:** ADR = la ley; Skill = la herramienta que cumple la
ley. Un ADR puede *exigir* usar un skill; un skill puede *asumir* un ADR. No
compiten: se complementan. Ejemplo del par: un ADR decide MVVM (la ley); un skill
genera ViewModels que cumplen MVVM (la herramienta). Mismo tema, distinto
artefacto. Ver `examples/`.

## Plantilla de SKILL.md (`skills/_staging/<skill-name>/SKILL.md`)

```markdown
---
name: <skill-name-en-kebab-case>
description: <una linea optimizada para disparo: cuando se usa y cuando NO; triggers explicitos>
version: 0.1.0
risk_class: safe
status: proposed
allowed-tools: Read, Write
owner: <quien lo propone>
approved_by:
---

# <Nombre del skill>

## Cuando usar este skill
<Triggers concretos. Situaciones en las que aplica.>

## Cuando NO usar este skill (anti-triggers)
<Situaciones en las que NO aplica, para evitar disparos falsos.>

## Procedimiento
<Las instrucciones / pasos / capacidad. Esto es lo que el agente ejecuta.>

## Ejemplos (golden cases)
<1-2 invocaciones de ejemplo con su resultado esperado.>

## Convenciones que asume
<Que ADRs / convenciones da por sentadas, p.ej. "asume ADR-0007: apps en MVVM".>
```

## Plantilla de proposal.md (`skills/_staging/<skill-name>/proposal.md`)

```markdown
# Propuesta de skill -- <skill-name>

## Rationale
<Por que debe existir. Que patron recurrente estandariza. Cuantas veces ha
aparecido la necesidad.>

## Scope (a quien sirve)
<Que agentes y/o stacks usan este skill.>

## Risk class + justificacion
<safe | elevated y por que. Si elevated: que tool nueva / riesgo concede y quien
es el approver nominado.>

## Casos de evaluacion
- Triggers (debe dispararse): <ejemplos>
- Anti-triggers (NO debe dispararse): <ejemplos>
- Golden case: <input -> output esperado>

## Comprobacion de solape
<Existe ya un skill que hace esto? Por que no basta con el existente?>
```
