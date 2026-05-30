# ADR-0023 -- Emparejamiento BLE inicial del Pulsar con handshake de nonce

> EJEMPLO ILUSTRATIVO de ADR DE US (Scope de feature). No es una decision real
> de la empresa. Vive en examples/ a proposito: init.sh no lo valida.

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
