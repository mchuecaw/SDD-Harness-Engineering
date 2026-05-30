# Requirements — <feature-name>

> Feature #<id> del `feature_list.json`. <Una frase describiendo la feature.>
>
> Cada requirement está redactado en EARS estricto (ver `docs/specs.md`) y es
> verificable por al menos un test concreto. Copia esta plantilla a
> `specs/<feature-name>/requirements.md` y rellénala.

## R1
<Patrón EARS>. El sistema DEBE <acción concreta y verificable>.

## R2
SI <evento no deseado> ENTONCES el sistema DEBE <acción>.

## R3
CUANDO <disparador>, el sistema DEBE <acción>.

<!-- Añade tantos R<n> como haga falta. Un solo DEBE por requirement. -->

## Trazabilidad con `acceptance` del feature_list.json

| Acceptance criterion (feature #<id>) | Cubierto por |
|--------------------------------------|--------------|
| <criterio 1 del acceptance>          | R1, R3       |
| <criterio 2 del acceptance>          | R2           |
| <criterio 3 del acceptance>          | ...          |
