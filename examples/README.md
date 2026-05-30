# examples/ -- artefactos de ejemplo (ilustrativos, NO activos)

> Estos archivos son **ejemplos de referencia** para ver el formato relleno de
> un PRD, dos ADRs (uno fundacional, uno de US) y un skill. Usan el dominio
> Wallbox (cargadores de vehiculo electrico) solo por ser cercano y reconocible;
> no son decisiones internas reales de ninguna empresa.

## Por que viven aqui y no en su sitio "real"

A proposito estan **fuera** de los paths activos del arnes, para que no
interfieran con la verificacion:

- Los ADRs de ejemplo estan en `examples/adr/`, no en `docs/adr/`, asi que
  `init.sh` no los valida ni los cuenta como ADRs del proyecto.
- El skill de ejemplo esta en `examples/skills/`, no en `skills/_staging/` ni en
  `.claude/skills/`, y **no** tiene entrada en `skills/registry.json`, asi que
  no esta publicado ni afecta a ningun agente.

Cuando arranques tu proyecto: borra `examples/` o usalo como molde, pero crea
tus artefactos reales en `docs/adr/`, `skills/_staging/` y `templates/prd.md`.

## Indice

| Ejemplo | Archivo | Ilustra |
|---------|---------|---------|
| PRD Eco-Smart (carga solar) | `prd-eco-smart.md` | PRD de MVP a nivel Epic + Use Case |
| ADR fundacional | `adr/ADR-0007-apps-moviles-mvvm.md` | `Scope: stack:ios, stack:android` (la "ley") |
| ADR de US | `adr/ADR-0023-emparejamiento-ble-nonce.md` | `Scope: feature:US-031` (decision local) |
| Skill | `skills/scaffold-mvvm-viewmodel/` | un skill que CUMPLE el ADR-0007 (la "herramienta") |

## El contraste en una linea

ADR-0007 *decide* que las apps van en MVVM (la ley, radio: todo el movil). El
skill `scaffold-mvvm-viewmodel` *genera* ViewModels que cumplen MVVM (la
herramienta, radio: todos los agentes que crean pantallas). Mismo tema, distinto
artefacto: uno restringe, el otro acelera.
