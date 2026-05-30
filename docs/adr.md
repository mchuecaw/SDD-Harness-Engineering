# ADR -- Architecture Decision Records (dos niveles)

> Un ADR registra una decision tecnica con consecuencias: el contexto que la
> fuerza, la decision en imperativo verificable, sus consecuencias y al menos
> una alternativa descartada. Un ADR no hace nada: documenta una eleccion que
> restringe el trabajo futuro. Plantilla en `docs/adr/_template.md`; indice en
> `docs/adr/README.md`.

## Donde encaja un ADR

Es la capa por encima del spec: mientras `design.md` decide cosas a nivel de una
feature, el ADR captura las decisiones que **sobreviven a la feature** y que
`docs/architecture.md` consolida. De hecho, `architecture.md` pasa a ser la
consolidacion legible de los ADRs fundacionales `accepted`: la regla del repo
"si no esta en architecture.md, no es un requisito" queda respaldada por
decisiones trazables, no por costumbre.

## Los dos niveles (se derivan del Scope)

Una decision arquitectonica no tiene un unico nivel. Hay dos tipos, con
disparadores distintos pero **el mismo mecanismo**:

**ADR fundacional (de stack o global).** Las convenciones que eliges *antes* de
tocar una sola US y que rigen todo el trabajo: "en Swift usamos MVVM",
"arquitectura hexagonal en el backend", "el firmware no usa asignacion dinamica
tras el arranque", taxonomia de errores comun, SemVer. Se deciden en *inception*,
su `Scope` es `global` o `stack:<...>`, y son **lectura obligatoria** para todo
`spec_author`. Pueblan `docs/adr/` y se resumen en `docs/architecture.md` antes
de la primera US. Radio enorme: condicionan a todas las US de su stack.

**ADR de US (de feature).** La decision significativa que aflora en el
`design.md` de una US concreta: "para el emparejamiento BLE de esta pantalla
usamos un handshake con nonce en vez del pairing estandar". Su `Scope` es
`feature:<US-id>` (o varios stacks si cruza). Se dispara en design-time. Radio
local a una US, aunque la decision sea durable.

Lo importante: **es la misma maquina** (`proposed -> puerta humana -> accepted`),
solo cambian el `Scope` y el *momento*. El nivel **no es un campo propio: se
deriva del `Scope`**, que es la unica fuente de verdad del alcance y del nivel:

```
Scope: global          -> fundacional
Scope: stack:<x>       -> fundacional
Scope: feature:<US-id> -> de US
```

Por eso el `spec_author` primero **lee** los ADRs fundacionales `accepted` (via
`architecture.md`) y, si durante el diseno topa con una decision significativa
nueva, la **promueve** como ADR de US.

## El campo Scope (multi-stack)

El ADR es agnostico de stack en mecanismo y consciente de stack en alcance:

- `global` -- vincula a todos los stacks (taxonomia de errores, SemVer,
  protocolo cargador-nube...).
- `stack:ios` / `stack:android` / `stack:web` / `stack:be` / `stack:embedded` --
  vincula solo a ese stack.
- `feature:<US-id>` -- ADR de US, local a una feature.
- Multiples scopes cuando la decision cruza varios (p. ej. el contrato de una
  API compartida: `stack:web, stack:ios, stack:be`).

## Ciclo de vida

```
decision significativa (inception O design-time)
   -> ADR proposed (con Scope)
   -> [puerta humana: acepta]
   -> accepted  (actualiza architecture.md si es fundacional)
   -> design.md referencia el ADR; el reviewer lo verifica
```

- **Inmutabilidad.** Un ADR `accepted` no se edita. Si cambia (p. ej. migrar de
  MVVM a TCA), se escribe un ADR nuevo con `Supersedes: ADR-XXXX` y el viejo pasa
  a `superseded by ADR-YYYY`. Los `superseded` no se borran.
- **Inception (paso nuevo).** Una fase corta "sembrar ADRs fundacionales por
  stack" antes de la primera US. Es donde encajan las convenciones de
  Swift/Android/Web/BE/embedded.
- **Mono-repo (por defecto).** Todos los ADRs en `docs/adr/`, el `Scope`
  particiona. **Multi-repo (un arnes por stack):** los `global`/compartidos
  viven en un repo raiz que cada stack referencia; los de stack viven en su
  repo. El mecanismo no cambia.

## Quien hace que

- `spec_author`: lee los ADRs fundacionales `accepted` antes de redactar
  `design.md`; promueve un ADR `proposed` con `Scope: feature:<US>` si aflora una
  decision significativa, y para hasta su puerta humana.
- Humano: acepta o rechaza el ADR `proposed` (puerta humana).
- `orquestador`: es el unico que promociona un ADR a `accepted`, y solo tras la
  firma humana.
- `reviewer`: verifica que cada decision de `design.md` traza a un ADR `accepted`
  o a `architecture.md`, el formato (>=1 alternativa, `Scope`), y que ninguno
  contradice a un ADR `accepted` sin supersede (checkpoint C8).

## ADR vs Skill (no confundir)

ADR = la ley (registra una DECISION, restringe lo que se construye). Skill = la
herramienta que cumple la ley (automatiza una TAREA repetible, acelera como se
construye). Ver `docs/skills.md` seccion "ADR vs Skill". Ejemplos en `examples/`.
