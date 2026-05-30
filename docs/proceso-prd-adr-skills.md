# SDD + Harness Engineering -- Proceso, Artefactos y Plantillas

> **Para Claude Code.** Este documento es contexto de diseno, no codigo. Describe
> como extender el repositorio `SDD-Harness-Engineering` con tres piezas que hoy
> no existen como artefactos: la jerarquia del "que" (PRD -> Epic -> User Story),
> los ADRs en dos niveles, y la gobernanza de Skills. El objetivo es que, tras
> implementarlo, el repo sea 100% funcional sin romper nada de lo existente.
>
> **Principio rector:** no se inventa un sistema de gobernanza nuevo. El repo ya
> tiene el patron (artefacto -> agente autor -> agente revisor -> puerta humana ->
> promocion a "en efecto" -> historial inmutable; nadie se autoaprueba; estado en
> disco; verificado por `init.sh` y `CHECKPOINTS.md`). Aqui ese mismo patron se
> instancia para dos artefactos mas, ordenados por su radio de impacto.
>
> **Convenciones de este repo que hay que respetar al implementar:**
> - Sin emoji dentro de archivos `.md` (rompen en shell). Usar texto plano.
> - Flechas en ASCII (`->`, `<->`), no Unicode.
> - El estado vive en disco y es verificable. Toda regla nueva debe tener un
>   checkpoint que la haga ejecutable.
> - Lo inmutable no se reescribe: se supera (supersede), no se edita.

---

## 0. Indice de implementacion (resumen para Claude Code)

Archivos NUEVOS a crear:

- `docs/prd.md` -- guia del PRD (resumen de la seccion 2 de este doc).
- `docs/adr.md` -- guia de ADRs de dos niveles (seccion 3).
- `docs/skills.md` -- guia + politica de subida de Skills (seccion 4).
- `docs/adr/README.md` -- indice de ADRs (fundacionales y de feature).
- `docs/adr/_template.md` -- plantilla de ADR (seccion 7.2).
- `templates/prd.md` -- plantilla de PRD (seccion 7.1).
- `skills/registry.json` -- registro de skills y su estado (seccion 7.4).
- `skills/_staging/.gitkeep` -- area de propuesta (fuera del path activo).
- `.claude/skills/.gitkeep` -- path activo de skills publicados.
- `.claude/agents/skill_author.md` -- agente que redacta skills en staging.
- `.claude/agents/skill_reviewer.md` -- agente que valida skills.

Archivos a EDITAR:

- `AGENTS.md` -- anadir al mapa: `docs/adr/`, `skills/`, los agentes nuevos.
- `CLAUDE.md` -- anadir reglas: el orquestador promociona ADR/skill solo tras
  su puerta humana; no entra nada en `.claude/skills/` sin firma humana.
- `CHECKPOINTS.md` -- anadir C7 (Skills) y C8 (ADRs). Ver seccion 9.
- `docs/methodology.md` -- anadir la tabla de los tres radios de impacto y la
  jerarquia PRD -> Epic -> US por encima del flujo SDD.
- `docs/specs.md` -- nota: `design.md` referencia ADRs `accepted`; el reviewer
  verifica esa trazabilidad.
- `.claude/agents/spec_author.md` -- protocolo: leer ADRs fundacionales antes de
  redactar `design.md`; promover un ADR de US si aflora una decision significativa.
- `.claude/agents/reviewer.md` -- verificar que cada decision de `design.md`
  traza a un ADR `accepted` o a `architecture.md`.
- `init.sh` -- validar invariantes de `skills/registry.json` y `docs/adr/`.

Decision de arquitectura por defecto: **mono-repo**. El campo `Scope` de los
ADRs particiona por stack; `.claude/skills/` es compartido. (Variante multi-repo
en la seccion 3.4.)

---

## 1. El proceso en una frase

Un PRD entra, se descompone en Epics y estos en User Stories; cada US recorre el
ciclo SDD (requirements EARS -> design -> tasks -> code) dentro del arnes; durante
la fase de spec se enganchan dos carriles de gobernanza (ADR y Skill), cada uno
con su propia puerta humana; cuando la US queda `spec_ready` y un humano aprueba
el spec, arranca el desarrollo.

### 1.1 Los tres artefactos y su radio de impacto

Esta es la idea que unifica todo. Los tres artefactos siguen el mismo patron de
gobernanza; lo unico que cambia es **cuanto se rompe si se equivocan**, y por eso
la puerta es mas estricta cuanto mayor es el radio.

| Artefacto        | Radio de impacto                  | Vive en                     | Maquina de estados                              | Puerta humana            |
|------------------|-----------------------------------|-----------------------------|-------------------------------------------------|--------------------------|
| Feature (US/SDD) | una feature, `src/`               | `specs/<feature>/`          | pending -> spec_ready -> in_progress -> done    | spec_ready (la que ya existe) |
| ADR              | un stack o todos, larga vida      | `docs/adr/ADR-XXXX.md`      | proposed -> accepted -> superseded              | proposed                 |
| Skill            | todos los agentes y sesiones      | `.claude/skills/<skill>/`   | proposed -> review -> approved -> published     | proposed (doble llave)   |

Regla: una feature la "aprueban" los tests. Un ADR lo aprueba un humano porque
sobrevive a la feature. Un skill exige doble llave humana, versionado y
supersede-no-overwrite porque reescribe el comportamiento de todos los agentes
que vengan despues.

---

## 2. Artefactos del "que": PRD -> Epic -> User Story

### 2.1 PRD (Product Requirements Document)

El PRD es el documento de producto. Responde al **porque** y al **que de alto
nivel**. Es la fuente de la que cuelga todo lo demas: cada Epic del PRD se
descompone en User Stories, y cada User Story se vuelve una feature `"sdd": true`
en `feature_list.json` con su propio spec.

El PRD captura, en este orden de importancia:

1. **Business problem to solve** -- el problema de negocio o de usuario que duele
   hoy, con evidencia, sin proponer todavia la solucion.
2. **Business Case / Impact** -- la seccion mas importante. Por que ahora, cual es
   el coste de no hacerlo, y el impacto esperado expresado en una metrica de
   negocio (ingresos, retencion, attach rate, coste evitado, NPS) aunque sea un
   orden de magnitud. Un PRD sin business case es una lista de deseos.
3. **Objetivos y metricas de exito** -- KPIs medibles con linea base y meta.
4. **Usuarios objetivo** -- 1-3 personas con su job-to-be-done.
5. **Scope** -- lo que el MVP hace, y de forma explicita lo que NO hace.
6. **Epics con Use Cases** -- el cuerpo del PRD (ver 2.2).
7. Assumptions, dependencies, risks, non-goals, open questions.

### 2.2 Epic y Use Cases

Un **Epic** es una capacidad coherente con un outcome de negocio. En el PRD, cada
Epic se describe con su outcome, su prioridad (must/should/could) y un conjunto de
**Use Cases**.

Un **Use Case** se escribe a nivel conversacional: `Como <actor>, quiero <objetivo>
para <valor>`. Todavia NO es Gherkin ni tiene criterios de aceptacion formales:
eso aparece mas tarde, cuando el Use Case se descompone en User Stories y cada US
obtiene sus requirements EARS en `specs/<us>/requirements.md`.

### 2.3 User Story

Una **User Story** es la unidad ejecutable. Es lo que aterriza en
`feature_list.json` como una feature `"sdd": true` y arranca el ciclo SDD del
repo. La US ya tiene `acceptance` concretos (que el `spec_author` convierte en
`R<n>` EARS). Una US debe ser pequena: cabe en un spec y se construye en una
sesion.

Trazabilidad del "que": **PRD -> Epic -> Use Case -> User Story -> feature_list.json
-> specs/<us>/**.

### 2.4 Limite de detalle recomendado (nivel MVP) -- IMPORTANTE

El error mas comun es meter demasiado detalle en el PRD. La regla:

> El PRD se detiene a nivel **Epic + Use Case**. No baja a User Stories, ni a
> criterios de aceptacion EARS, ni a diseno tecnico.

Concretamente, un PRD de MVP:

- Tiene del orden de **3 a 8 Epics**, cada uno con **2 a 6 Use Cases**.
- Cabe en unas **2 a 5 paginas**. Si crece mas, esta entrando en territorio de
  spec o de ADR.
- **NO** enumera todas las User Stories (esas se derivan despues, al refinar).
- **NO** contiene criterios de aceptacion EARS (`R<n>`) -- eso es
  `specs/<us>/requirements.md`.
- **NO** contiene diseno tecnico, firmas, esquemas ni contratos de API -- eso es
  `design.md` y los ADRs.
- **NO** contiene mockups de UI detallados; como mucho, bocetos de bajo nivel.

Frontera mental: el PRD dice **que problema y que capacidades** (Epic + Use Case);
el spec de cada US dice **que tiene que cumplir exactamente** (EARS); el ADR dice
**que decidimos tecnicamente** y `design.md` **como se construye esta US**.

---

## 3. ADRs (Architecture Decision Records) -- dos niveles

### 3.1 Que es un ADR

Un ADR registra **una decision tecnica con consecuencias**: el contexto que la
fuerza, la decision en imperativo verificable, sus consecuencias y al menos una
alternativa descartada. Un ADR no hace nada: documenta una eleccion que
restringe el trabajo futuro. Es la capa por encima del spec: mientras
`design.md` decide cosas a nivel de una feature, el ADR captura las decisiones
que sobreviven a la feature y que `docs/architecture.md` consolida.

### 3.2 Por que dos niveles

Esta es la parte clave, tal y como la conversamos. Una decision arquitectonica
no tiene un unico nivel. Hay dos tipos, con disparadores distintos pero **el
mismo mecanismo**:

**ADR fundacional (de stack o global).** Son las convenciones que eliges *antes*
de tocar una sola US y que rigen todo el trabajo: "en Swift usamos MVVM",
"arquitectura hexagonal en el backend", "el firmware no usa asignacion dinamica
tras el arranque", taxonomia de errores comun, versionado SemVer. Se deciden en
inception, su `Scope` es `global` o `stack:<...>`, y son **lectura obligatoria**
para todo `spec_author`. Pueblan `docs/adr/` y se resumen en
`docs/architecture.md` antes de la primera US. Su radio es enorme: condicionan a
todas las US de su stack.

**ADR de US (de feature).** Es la decision significativa que aflora en el
`design.md` de una US concreta: "para el emparejamiento BLE de esta pantalla
usamos un handshake con nonce en vez del pairing estandar". Su `Scope` es
`feature:<US-id>` (o varios stacks si la decision los cruza). Se dispara en
design-time. Su radio es local a una US, aunque la decision en si sea durable.

Lo importante: **es la misma maquina** (`proposed -> puerta humana -> accepted`),
solo cambian el `Scope` y el *momento*. La distincion es de leverage y de timing:
los fundacionales se ganan una puerta al inicio porque condicionan todo; los de US
se ganan una puerta en el design de esa US porque ahi es donde la decision se hace
mas grande que la feature. Por eso el `spec_author` primero **lee** los ADRs
fundacionales `accepted` (via `architecture.md`) y, si durante el diseno topa con
una decision significativa nueva, la **promueve** como ADR de US.

El nivel (fundacional vs de US) **no es un campo propio del ADR: se deriva del
`Scope`**. `Scope: global` o `Scope: stack:<...>` => fundacional; `Scope:
feature:<US-id>` => de US. Asi no hay redundancia ni dos campos que puedan
contradecirse: el `Scope` es la unica fuente de verdad del alcance y del nivel.

### 3.3 El campo Scope (multi-stack)

El ADR es agnostico de stack en mecanismo (un flujo, un formato, una maquina de
estados) y consciente de stack en alcance (un campo). El `Scope` es la particion:

- `global` -- vincula a todos los stacks (p. ej. taxonomia de errores, SemVer,
  protocolo cargador-nube).
- `stack:ios` / `stack:android` / `stack:web` / `stack:be` / `stack:embedded` --
  vincula solo a ese stack (p. ej. `stack:embedded`: "sin malloc tras init";
  `stack:be`: "todo endpoint pagina").
- `feature:<US-id>` -- ADR de US, local a una feature.
- Multiples scopes cuando la decision cruza varios (p. ej. el contrato de una API
  compartida: `stack:web, stack:ios, stack:be`).

`docs/architecture.md` pasa a ser la consolidacion legible de los ADRs
fundacionales `accepted`. Asi la regla del repo "si no esta en architecture.md, no
es un requisito" queda respaldada por decisiones trazables, no por costumbre.

### 3.4 Ciclo de vida y como se conecta

```
decision significativa (inception O design-time)
   -> ADR proposed (con Scope)
   -> [puerta humana: acepta]
   -> accepted  (actualiza architecture.md)
   -> design.md referencia el ADR; el reviewer lo verifica
```

- Inmutabilidad: un ADR `accepted` no se edita. Si cambia (p. ej. migrar de MVVM
  a TCA), se escribe un ADR nuevo con `Supersedes: ADR-XXXX` y el viejo pasa a
  `superseded by ADR-YYYY`. Los superseded no se borran.
- **Inception (paso nuevo):** una fase corta "sembrar ADRs fundacionales por
  stack" antes de la primera US. Es donde encajan las convenciones de
  Swift/Android/Web/BE/embedded.
- **Mono-repo (por defecto):** todos los ADRs en `docs/adr/`, el `Scope`
  particiona. **Multi-repo (un arnes por stack):** los `global` y compartidos
  viven en un repo raiz que cada stack referencia; los de stack viven en su repo.
  El mecanismo no cambia.

---

## 4. Skills -- gobernanza global

### 4.1 Que es un skill (y por que es global)

Un skill es una **capacidad o procedimiento reutilizable** que un agente ejecuta:
boilerplate, scaffolding, una validacion estandarizada, una transformacion. A
diferencia de un ADR (que registra una decision), un skill *hace* algo, muchas
veces.

Un skill es transversal por naturaleza: se inyecta en el comportamiento de
**todos los agentes en todas las sesiones y stacks**. Un skill malo no rompe una
feature: envenena la metodologia. Por eso su radio de impacto es el mayor de los
tres y su puerta es la mas estricta.

### 4.2 Politica de subida (con approvals)

El mismo patron de SDD, con dos refuerzos:

1. **`skills/_staging/<skill>/`** -- area de propuesta. Mientras un skill esta
   aqui NO esta en el path activo (`.claude/skills/`), asi que fisicamente no
   puede afectar a ningun agente. La puerta la impone el sistema de archivos,
   igual que con los specs.
2. **`skills/registry.json`** -- una entrada por skill con `status`
   (proposed -> review -> approved -> published, mas rejected/deprecated),
   `risk_class`, `version`, `proposed_by`, `reviewed_by`, `approved_by`, `date`.
3. Una propuesta de skill son dos archivos: `SKILL.md` (el skill) y `proposal.md`
   (rationale, scope, risk_class, casos de evaluacion). Ver plantillas en 7.3.

Agentes y puerta:

- `skill_author` -- redacta `SKILL.md` + `proposal.md` en staging. No publica.
- `skill_reviewer` -- valida: triggers (dispara cuando debe y NO cuando no debe),
  convenciones, solape con skills existentes, riesgo no documentado. Emite
  APPROVED / CHANGES_REQUESTED. No publica.
- **Puerta humana (doble llave):** el orquestador promociona staging ->
  `.claude/skills/` solo cuando hay `skill_reviewer: APPROVED` Y aprobacion
  humana explicita. Nada entra en el path activo sin firma humana.

Dos refuerzos sobre la puerta de SDD:

- **Clase de riesgo.** `risk_class: safe | elevated`. Un skill `elevated` (concede
  tools nuevas, toca seguridad, deploy, dinero o borrados) exige un approver
  humano nominado y, opcionalmente, un segundo revisor.
- **Supersede-no-overwrite.** Cambiar un skill aprobado se hace subiendo una
  version nueva que vuelve a pasar la puerta, no editandolo en sitio. La
  provenance queda en el registry.

### 4.3 Disparador y efecto

- **Disparador:** la recurrencia. Un skill se justifica cuando la misma forma se
  ha repetido en dos o tres US. Puede aflorar desde cualquier fase (es donde se
  *descubre*).
- **Efecto:** global. Una vez `published`, lo consumen todos los agentes
  (orquestador, spec_author, implementer, reviewer). Se descubre a nivel US pero
  vive por encima de todo el sistema.

---

## 5. ADR vs Skill -- como decidir (para Claude)

Esta es la distincion que mas se confunde. Cinco preguntas litmus:

1. ¿Registra una DECISION (con alternativas y consecuencias) o automatiza una
   TAREA repetible? Decision -> ADR. Tarea -> Skill.
2. ¿RESTRINGE lo que se puede construir, o ACELERA como se construye?
   Restringe -> ADR. Acelera -> Skill.
3. Si manana cambia, ¿reescribes una decision (ADR nuevo que supera al anterior)
   o actualizas un procedimiento (version nueva del skill)?
4. ¿Tiene sentido la pregunta "que alternativas se consideraron"? Si -> ADR. Un
   skill no considera alternativas, ejecuta un procedimiento.
5. ¿Lo lees una vez para entender el porque (ADR) o lo invocas muchas veces para
   hacer algo (Skill)?

**Relacion complementaria (clave):** ADR = la ley; Skill = la herramienta que
cumple la ley. Un ADR puede *exigir* usar un skill ("DEBE usarse el skill X"); un
skill puede *asumir* un ADR (el skill genera codigo que respeta la arquitectura
que el ADR eligio). No compiten: se complementan.

Ejemplos contrastados (contexto Wallbox, ilustrativos):

| Situacion                                                              | ADR o Skill        | Por que |
|------------------------------------------------------------------------|--------------------|---------|
| "Las apps moviles myWallbox usan MVVM + capa de dominio"               | ADR (fundacional)  | decision con alternativas y consecuencias; restringe |
| "Generar un ViewModel nuevo de myWallbox siguiendo MVVM"               | Skill              | tarea repetible que CUMPLE el ADR de MVVM |
| "El firmware del cargador no usa malloc tras el arranque"              | ADR (fundacional, embedded) | decision arquitectonica durable |
| "Validar y serializar un mensaje OCPP contra su esquema JSON"          | Skill              | procedimiento repetible |
| "Comunicacion cargador-nube via OCPP 1.6J sobre WebSocket con TLS"     | ADR (fundacional, global) | decision de protocolo; restringe |
| "El emparejamiento BLE de ESTA pantalla usa un handshake con nonce"    | ADR (de US)        | decision significativa local a una US |
| "Scaffolding de una migracion de la tabla de sesiones de carga"        | Skill              | tarea repetible estandarizada |
| "El endpoint /sessions pagina por cursor (no por offset)"              | ADR (de US / be)   | decision de diseno durable |

Observa el par MVVM: el ADR *decide* MVVM (la ley); el skill *genera* un ViewModel
siguiendo MVVM (la herramienta que cumple la ley). Mismo tema, distinto artefacto.

---

## 6. Roles del sistema

### 6.1 Agentes

| Agente          | Responsabilidad                                                | Tools |
|-----------------|----------------------------------------------------------------|-------|
| `orquestador`   | Descompone y coordina; gobierna transiciones de estado; detiene en las puertas humanas; promociona artefactos tras su gate. Nunca codifica. | Read, Glob, Grep, Bash, Agent |
| `explorer`      | Investigacion de solo-lectura; escribe hallazgos en `progress/explore_<tema>.md`. | Read, Glob, Grep, Bash |
| `spec_author`   | Redacta specs (requirements EARS / design / tasks); lee ADRs fundacionales; promueve ADRs de US. Nunca codifica. | Read, Write, Edit, Glob, Grep, Bash |
| `implementer`   | Implementa una feature segun su spec aprobado; escribe codigo y tests; garantiza trazabilidad `R<n>` -> test. | Read, Write, Edit, Glob, Grep, Bash |
| `reviewer`      | Aprueba o rechaza; verifica trazabilidad `R<n>` -> test, tasks completas, checkpoints, y los ADRs: que cada decision de `design.md` traza a un ADR `accepted` o a `architecture.md`, su formato (>=1 alternativa, `Scope`) y que ninguno contradice a un ADR `accepted` sin supersede. Nunca edita. | Read, Glob, Grep, Bash |
| `skill_author`  | (nuevo) Redacta `SKILL.md` + `proposal.md` en `skills/_staging/`. No publica. | Read, Write, Edit, Glob, Grep, Bash |
| `skill_reviewer`| (nuevo) Valida skills: triggers, scope, solape, riesgo. Emite veredicto. No publica. | Read, Glob, Grep, Bash |

### 6.2 El orquestador

Es el director. No hace el trabajo: lo reparte. Recibe la tarea, descompone,
lanza subagentes, gobierna los estados de `feature_list.json` y del registry de
skills, y **detiene el flujo en cada puerta humana**. Es el unico que promociona
un artefacto a su estado "en efecto" (spec aprobado -> `in_progress`; ADR ->
`accepted`; skill -> `published`), y solo despues de la firma humana.

### 6.3 Human-in-the-loop (separacion de poderes)

El humano tiene las llaves de las tres puertas (spec, ADR, skill). Es el punto de
maximo apalancamiento: corregir un spec, un ADR o un skill cuesta minutos;
corregir codigo equivocado cuesta horas. Ningun agente se autoaprueba: el que
redacta no revisa, el que revisa no aprueba, el que aprueba no codifica.

### 6.4 El human-in-the-loop en el tiempo (importante)

Al principio, el human-in-the-loop debe estar **presente de forma intensiva en
todas las puertas**. Valida cada propuesta de spec, cada ADR y cada skill. El
objetivo de esa presencia es doble:

- **Entrenar a los agentes:** afinar sus definiciones (`.claude/agents/*.md`), las
  convenciones (`docs/`) y los ADRs fundacionales hasta que cada agente produzca
  output consistente con el dominio del proyecto.
- **Verificar que el sistema funciona como un reloj:** que los checkpoints
  (C1-C8) pasan de forma fiable sin intervencion, que las propuestas llegan
  correctas a la primera la mayoria de las veces, y que los rechazos del reviewer
  caen.

A medida que sube la confianza, el humano **delega progresivamente** las puertas
de menor radio: primero los specs de US triviales, luego las medias. Reserva su
atencion para lo de mayor radio: los ADRs fundacionales y los skills `elevated`.

El humano **nunca desaparece** de las puertas `elevated` (ADRs fundacionales y
skills que tocan seguridad, deploy, dinero o borrados). Esas mantienen firma
humana siempre, por mucho que el sistema este afinado.

---

## 7. Plantillas

### 7.1 Plantilla de PRD (`templates/prd.md`)

```markdown
# PRD -- <Nombre del producto / MVP>

> Nivel: MVP (v1) | Estado: draft | Version: 0.1 | Fecha: AAAA-MM-DD | Autor: <nombre>
>
> Limite de detalle: este PRD define el QUE y el PORQUE a nivel Epic + Use Case.
> NO baja a User Stories, ni a criterios de aceptacion EARS, ni a diseno tecnico.

## 1. Business problem to solve
<El problema de negocio/usuario en 1-3 parrafos. Que duele hoy, a quien, con que
evidencia. Sin proponer solucion todavia.>

## 2. Business Case / Impact   [la seccion mas importante]
- Por que ahora: <ventana de oportunidad, presion competitiva, regulacion...>
- Coste de no hacerlo: <que perdemos si no lo hacemos>
- Impacto esperado (medible): <metrica de negocio con orden de magnitud>
- Inversion estimada (orden de magnitud): <esfuerzo, no presupuesto exacto>
- North star (metrica que define ganar): <una metrica>

## 3. Objetivos y metricas de exito (KPIs)
| Objetivo | Metrica | Linea base | Meta MVP |
|----------|---------|------------|----------|
| <obj 1>  | <kpi>   | <hoy>      | <meta>   |

## 4. Usuarios objetivo (personas)
<1-3 personas: quien, contexto, job-to-be-done. Sin sobre-detallar.>

## 5. Scope
In-scope (MVP):
- <capacidad 1>
- <capacidad 2>

Out-of-scope (explicito, lo que el MVP NO hace):
- <fuera 1>
- <fuera 2>

## 6. Epics y Use Cases
> Cada Epic = una capacidad con outcome de negocio. Cada Use Case = actor +
> objetivo + valor, a nivel conversacional. Cada Epic se descompondra en User
> Stories que entran en feature_list.json.

### Epic E1 -- <nombre>
- Outcome de negocio: <que cambia cuando esto existe>
- Prioridad: must | should | could
- Use Cases:
  - UC1.1 -- Como <actor>, quiero <objetivo> para <valor>.
  - UC1.2 -- Como <actor>, quiero <objetivo> para <valor>.

### Epic E2 -- <nombre>
- ...

## 7. Assumptions y constraints
- <supuesto / restriccion>

## 8. Dependencies y risks
- <dependencia externa / riesgo + mitigacion>

## 9. Non-goals
- <decision deliberada de NO hacer X en el MVP>

## 10. Open questions
- <pregunta abierta pendiente>

## 11. Trazabilidad PRD -> ejecucion
| Epic | User Stories (ids feature_list) |
|------|----------------------------------|
| E1   | US-001, US-002 ...               |
```

### 7.2 Plantilla de ADR (`docs/adr/_template.md`)

```markdown
# ADR-XXXX -- <titulo de la decision>

- Status: proposed | accepted | superseded by ADR-YYYY | deprecated
- Scope: global | stack:ios | stack:android | stack:web | stack:be | stack:embedded | feature:<US-id>   (uno o varios; el Scope define el nivel: global/stack => fundacional, feature => de US)
- Date: AAAA-MM-DD
- Deciders: <quien decide / aprueba>
- Supersedes: <ADR-ZZZZ o ninguno>

## Contexto
<Que fuerza esta decision: problema tecnico, restricciones, que esta en juego.>

## Decision
El proyecto / los <stack> DEBE <decision concreta, imperativa y verificable>.

## Consecuencias
- Positivas: <que ganamos>
- Negativas / coste: <que sacrificamos, deuda que aceptamos>
- Neutras: <efectos colaterales>

## Alternativas consideradas (minimo una)
1. <Alternativa A> -- descartada porque <razon>.
2. <Alternativa B> -- descartada porque <razon>.

## Afecta a
- Specs: <US/features que dependen de esta decision>
- Skills: <skills que implementan o asumen esta decision>
- architecture.md: <seccion que esta decision consolida>

## Verificacion (como lo comprueba el reviewer)
<Que tiene que cumplir un design.md/codigo para respetar este ADR.>
```

### 7.3 Plantilla de Skill

`skills/_staging/<skill-name>/SKILL.md`:

```markdown
---
name: <skill-name-en-kebab-case>
description: <una linea optimizada para disparo: cuando se usa y cuando NO; triggers explicitos>
version: 0.1.0
risk_class: safe | elevated
status: proposed | review | approved | published
allowed-tools: <tools que el skill habilita, p.ej. Read, Write, Bash>
owner: <quien lo propone>
approved_by: <quien lo aprueba; vacio hasta published>
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

`skills/_staging/<skill-name>/proposal.md`:

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

### 7.4 Esquema de `skills/registry.json`

```json
{
  "skills": [
    {
      "name": "scaffold-mvvm-viewmodel",
      "version": "0.1.0",
      "status": "published",
      "risk_class": "safe",
      "scope": ["stack:ios", "stack:android"],
      "proposed_by": "<nombre>",
      "reviewed_by": "skill_reviewer",
      "approved_by": "<humano>",
      "date": "AAAA-MM-DD",
      "supersedes": null
    }
  ]
}
```

---

## 8. Ejemplos (contexto Wallbox, ilustrativos)

> Wallbox se usa solo como dominio cercano y reconocible (cargadores de vehiculo
> electrico: firmware embebido, apps iOS/Android, portal web, backend). Los
> ejemplos son ilustrativos, no decisiones internas reales de la empresa.

### 8.1 PRD de ejemplo

```markdown
# PRD -- Eco-Smart: carga con excedente solar (MVP)

> Nivel: MVP (v1) | Estado: draft | Version: 0.1 | Fecha: 2026-05-30 | Autor: Producto

## 1. Business problem to solve
Los propietarios de vivienda con paneles fotovoltaicos quieren cargar el coche con
el excedente solar en vez de verterlo a la red a precio bajo. Hoy el cargador es
"tonto" respecto a la produccion solar: carga a corriente fija, ignorando cuanta
energia sobra en cada momento.

## 2. Business Case / Impact
- Por que ahora: el autoconsumo residencial crece y el precio de vertido a red es
  bajo; cargar con excedente es un ahorro tangible para el usuario.
- Coste de no hacerlo: perdemos diferenciacion frente a competidores que ya
  ofrecen carga solar; el cargador se percibe como commodity.
- Impacto esperado: aumento del attach rate del Pulsar Plus en hogares con FV y
  mayor retencion; posible upsell del medidor de energia. Orden de magnitud:
  decenas de miles de hogares objetivo en el primer ano.
- North star: porcentaje de energia de carga proveniente de excedente solar.

## 3. Objetivos y metricas de exito
| Objetivo                          | Metrica                          | Linea base | Meta MVP |
|-----------------------------------|----------------------------------|------------|----------|
| Cargar con excedente solar        | % energia de carga de origen solar | 0%       | > 60%    |
| Visibilidad para el usuario       | % usuarios FV que activan Eco-Smart | 0%      | > 40%    |

## 4. Usuarios objetivo
Propietario de vivienda unifamiliar con instalacion FV y un Pulsar Plus, que
quiere maximizar el autoconsumo sin tener que gestionarlo manualmente.

## 5. Scope
In-scope (MVP):
- Detectar el excedente solar disponible en cada momento.
- Modular la corriente de carga para usar solo el excedente.
- Mostrar en la app cuanta energia solar se ha usado para cargar.

Out-of-scope:
- V2G / devolver energia a la red.
- Gestion de varios cargadores (Power Sharing).
- Tarifas dinamicas de red.

## 6. Epics y Use Cases

### Epic E1 -- Medicion del excedente solar
- Outcome de negocio: el cargador conoce el excedente disponible en tiempo real.
- Prioridad: must
- Use Cases:
  - UC1.1 -- Como propietario, quiero que el cargador sepa cuanto excedente solar
    hay para poder usarlo.

### Epic E2 -- Modulacion de carga al excedente
- Outcome de negocio: el coche carga sin tirar de red mientras haya sol.
- Prioridad: must
- Use Cases:
  - UC2.1 -- Como propietario, quiero que el coche cargue solo con el excedente
    para no comprar energia a la red.
  - UC2.2 -- Como propietario, quiero un modo "solar + minimo de red" para no
    parar la carga si baja el sol.

### Epic E3 -- Visibilidad en la app
- Outcome de negocio: el usuario ve el valor del autoconsumo y confia en el modo.
- Prioridad: should
- Use Cases:
  - UC3.1 -- Como propietario, quiero ver cuanta energia solar he usado para
    cargar en la app.

## 9. Non-goals
- No optimizamos contra el precio de mercado en el MVP, solo contra el excedente.

## 11. Trazabilidad PRD -> ejecucion
| Epic | User Stories (ids feature_list) |
|------|----------------------------------|
| E1   | US-001, US-002                   |
| E2   | US-003, US-004                   |
| E3   | US-005                           |
```

### 8.2 ADR fundacional de ejemplo

```markdown
# ADR-0007 -- Las apps moviles myWallbox usan MVVM + capa de dominio

- Status: accepted
- Scope: stack:ios, stack:android
- Date: 2026-05-30
- Deciders: Lead movil, Arquitectura
- Supersedes: ninguno

## Contexto
Las apps iOS y Android comparten dominio (sesiones de carga, estado del cargador,
programaciones) pero divergen en UI. Sin una estructura comun, la logica de
negocio se mezcla con la UI y los tests son fragiles.

## Decision
Las apps moviles DEBEN estructurarse en MVVM con una capa de dominio independiente
del framework de UI (sin imports de UIKit/SwiftUI ni de Android en el dominio).

## Consecuencias
- Positivas: dominio testeable sin UI; paridad de arquitectura entre plataformas.
- Negativas / coste: mas boilerplate por pantalla (ViewModel + protocolo + test).
- Neutras: requiere disciplina de inyeccion de dependencias.

## Alternativas consideradas
1. MVC -- descartada por baja testabilidad y view controllers gigantes.
2. MVI / Redux unidireccional -- descartada por sobre-ingenieria para el MVP.

## Afecta a
- Specs: todas las US con pantalla nueva en movil.
- Skills: scaffold-mvvm-viewmodel (genera ViewModels que cumplen este ADR).
- architecture.md: seccion "Apps moviles".

## Verificacion
El dominio no importa frameworks de UI; cada pantalla tiene su ViewModel con test.
```

### 8.3 ADR de US de ejemplo

```markdown
# ADR-0023 -- Emparejamiento BLE inicial del Pulsar con handshake de nonce

- Status: accepted
- Scope: feature:US-031, stack:embedded, stack:ios, stack:android
- Date: 2026-05-30
- Deciders: Lead embedded, Seguridad
- Supersedes: ninguno

## Contexto
Durante el design de US-031 (onboarding del cargador via Bluetooth) hay que
decidir como autenticar el primer emparejamiento entre app y cargador.

## Decision
El emparejamiento inicial DEBE usar un handshake con un nonce generado por el
firmware y verificado por la app, en lugar del pairing "Just Works" de BLE.

## Consecuencias
- Positivas: mitiga ataques man-in-the-middle en el emparejamiento.
- Negativas / coste: mas complejidad en firmware y en la app; un paso mas en el
  onboarding.
- Neutras: requiere sincronizar el formato del nonce entre firmware y apps.

## Alternativas consideradas
1. Pairing "Just Works" de BLE -- descartado por exposicion a MITM.
2. PIN estatico impreso -- descartado por mala usabilidad y baja entropia.

## Afecta a
- Specs: US-031.
- Skills: ninguno (decision local).
- architecture.md: no modifica el contrato general; queda como decision de feature.

## Verificacion
El emparejamiento rechaza una sesion sin nonce valido; existe test del camino de
error.
```

### 8.4 Skill de ejemplo

`skills/_staging/scaffold-mvvm-viewmodel/SKILL.md`:

```markdown
---
name: scaffold-mvvm-viewmodel
description: Genera el boilerplate de un ViewModel nuevo de myWallbox siguiendo MVVM. Usar al crear una pantalla nueva en iOS o Android. NO usar para logica de dominio ni para vistas.
version: 0.1.0
risk_class: safe
status: proposed
allowed-tools: Read, Write
owner: Lead movil
approved_by:
---

# scaffold-mvvm-viewmodel

## Cuando usar este skill
Al crear una pantalla nueva en las apps moviles que necesita su ViewModel.

## Cuando NO usar este skill (anti-triggers)
- Para escribir logica de dominio (eso va en la capa de dominio, no en el VM).
- Para generar la vista (SwiftUI/Compose).
- Para pantallas que ya tienen ViewModel.

## Procedimiento
Dado el nombre de la pantalla y sus dependencias, genera: el ViewModel con su
protocolo, la inyeccion de dependencias estandar y un test base que verifica el
estado inicial. Sigue la estructura de la capa de dominio (sin imports de UI).

## Ejemplos (golden cases)
Input: pantalla "SessionHistory", dependencias [SessionRepository].
Output: SessionHistoryViewModel + SessionHistoryViewModelProtocol + test base.

## Convenciones que asume
Asume ADR-0007 (apps moviles en MVVM con capa de dominio independiente del
framework).
```

`skills/_staging/scaffold-mvvm-viewmodel/proposal.md`:

```markdown
# Propuesta de skill -- scaffold-mvvm-viewmodel

## Rationale
Crear un ViewModel a mano se ha repetido en US-005, US-012 y US-019 con la misma
estructura. Estandarizarlo reduce errores y acelera cada pantalla nueva.

## Scope (a quien sirve)
Al implementer en stacks stack:ios y stack:android.

## Risk class + justificacion
safe. Solo genera codigo de scaffolding; no toca seguridad, deploy ni datos.

## Casos de evaluacion
- Triggers: "crea el ViewModel de la pantalla X".
- Anti-triggers: "implementa la logica de dominio de X"; "crea la vista de X".
- Golden case: pantalla "SessionHistory" -> VM + protocolo + test base.

## Comprobacion de solape
No existe un skill de scaffolding de ViewModels. El de migraciones de BD no aplica.
```

### 8.5 El contraste en una linea

ADR-0007 *decide* que las apps van en MVVM (la ley, radio: todo el movil). El skill
scaffold-mvvm-viewmodel *genera* ViewModels que cumplen MVVM (la herramienta, radio:
todos los agentes que crean pantallas). Mismo tema, distinto artefacto: uno
restringe, el otro acelera.

---

## 9. Checklist de implementacion para Claude Code

Checkpoints nuevos a anadir en `CHECKPOINTS.md`:

```markdown
## C7 -- Gobernanza de Skills
- [ ] Todo directorio en `.claude/skills/` tiene una entrada `published` en
      `skills/registry.json`.
- [ ] Ningun skill `proposed`/`review` esta fisicamente en `.claude/skills/`
      (solo en `skills/_staging/`).
- [ ] Todo skill `published` tiene `approved_by` (humano) y `version`.
- [ ] Todo skill tiene `proposal.md` con casos de evaluacion (triggers,
      anti-triggers, golden case).

## C8 -- Gobernanza de ADRs
- [ ] Todo ADR `accepted` tiene `Status`, `Scope` y >= 1 alternativa.
- [ ] No hay dos ADR `accepted` que se contradigan en el mismo `Scope` sin un
      link de supersede.
- [ ] Cada decision tecnica de un `design.md` traza a un ADR `accepted` o a
      `docs/architecture.md`.
- [ ] Los ADR `superseded` no se han borrado.
```

Validaciones nuevas en `init.sh` (mismo espiritu que las de `feature_list.json`):

- Parsear `skills/registry.json`: que cada `name` con `status: published` tiene
  su directorio en `.claude/skills/<name>/` con `SKILL.md`, y que ningun skill
  no-publicado vive en `.claude/skills/`.
- Comprobar que existe `docs/adr/` con su `README.md` (indice) y que cada
  `ADR-XXXX.md` tiene cabecera con `Status` y `Scope`.

Ediciones de agentes:

- `spec_author.md`: anadir al protocolo "antes de redactar `design.md`, lee los
  ADR `accepted` cuyo `Scope` sea `global` o el de tu stack; cada decision de
  `design.md` debe trazar a un ADR `accepted` o a `architecture.md`; si aflora
  una decision significativa nueva, promueve un ADR con `Scope: feature:<US>` y
  paralo hasta su puerta humana".
- `reviewer.md`: anadir al protocolo la verificacion de C8: que cada decision de
  `design.md` traza a un ADR `accepted` o a `architecture.md`, el formato del ADR
  (>=1 alternativa, `Scope`) y que ninguno contradice a un ADR `accepted` sin
  supersede. La validacion de ADRs la hace el reviewer general; no se crea un
  agente revisor de arquitectura aparte.
- `orquestador.md` y `CLAUDE.md`: el orquestador es el unico que promociona un
  ADR a `accepted` o un skill a `published`, y solo tras la firma humana.

Estructura final esperada (anadidos):

```
docs/
  adr/
    README.md            # indice de ADRs (fundacionales y de feature)
    _template.md
    ADR-0001-....md
  adr.md                 # guia de ADRs (dos niveles)
  prd.md                 # guia del PRD
  skills.md              # guia + politica de subida de Skills
templates/
  prd.md
skills/
  registry.json
  _staging/.gitkeep
.claude/
  skills/.gitkeep
  agents/
    skill_author.md
    skill_reviewer.md
```

Fin del documento.
