# Indice de ADRs

> Architecture Decision Records de este proyecto. Guia completa en
> `docs/adr.md`; plantilla en `docs/adr/_template.md`. El nivel de cada ADR
> (fundacional vs de US) se deriva de su `Scope`, no de un campo aparte.

## Como anadir un ADR

1. Copia `_template.md` a `docs/adr/ADR-XXXX-<slug>.md` con el siguiente numero
   libre (4 digitos, p. ej. `ADR-0001-...`).
2. Rellena la cabecera. El `Status` arranca en `proposed`.
3. Pasa la puerta humana. Solo el `orquestador` lo promociona a `accepted`, y
   solo tras la firma humana.
4. Si es fundacional (`Scope: global` o `stack:<x>`), refleja su decision en
   `docs/architecture.md`.
5. Anade una fila a la tabla de abajo.

## ADRs fundacionales (Scope: global | stack:<x>)

> Lectura obligatoria para todo `spec_author`. Se siembran en inception.

| ADR | Titulo | Scope | Status |
|-----|--------|-------|--------|
| _(ninguno todavia -- siembra aqui las convenciones de tus stacks)_ | | | |

## ADRs de US (Scope: feature:<US-id>)

> Decisiones significativas que afloran en el `design.md` de una US concreta.

| ADR | Titulo | Scope | Status |
|-----|--------|-------|--------|
| _(ninguno todavia)_ | | | |

## Superseded / deprecated

> Los ADR superados no se borran: quedan aqui con su link de supersede.

| ADR | Titulo | Superseded by |
|-----|--------|---------------|
| _(ninguno todavia)_ | | |
