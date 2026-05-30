# Arquitectura — Qué significa "hacer un buen trabajo"

> **PLANTILLA.** Este documento define el estándar de calidad de TU proyecto.
> Los agentes (`spec_author`, `implementer`, `reviewer`) lo leen y evalúan el
> código contra él. **Si no está aquí, no es un requisito.** Reemplaza los
> ejemplos por las reglas reales de tu proyecto antes de empezar.

## Principios

> Lista los principios estructurales no negociables. Ejemplos de la forma que
> deberían tener (reemplázalos):

1. **Capas claras.** Define las capas de tu proyecto y prohíbe introducir
   nuevas sin justificación documentada en `feature_list.json`.
   *Ej.: `storage` (persistencia) → `domain` (modelo) → `interface` (API/CLI/UI).*

2. **Dependencias controladas.** Declara qué dependencias externas se permiten.
   Si una feature necesita una nueva, primero se discute (estado `blocked`).

3. **Errores explícitos.** Define cómo se señalan los fallos (excepciones
   nombradas, tipos `Result`, códigos de error...). Prohíbe el fallo silencioso.

4. **<Tu principio de modelado de datos>.** *Ej.: inmutabilidad por defecto,
   normalización, etc.*

5. **<Tu principio de IO / efectos>.** *Ej.: escrituras atómicas, no IO en la
   capa de dominio, etc.*

## Flujo de datos

> Dibuja (en ASCII basta) cómo fluye una petición a través de las capas, para
> que el agente sepa dónde encaja cada cambio. Ejemplo:

```
usuario / cliente
      │
      ▼
  interface  ──► domain  ──► storage  ──► (persistencia)
```

## Qué NO hacer

> Lista anti-patrones concretos para tu proyecto. Ejemplos:

- No mezclar IO con lógica de dominio.
- No leer/escribir en disco/red dentro de un bucle caliente.
- No introducir un sistema de configuración global ad-hoc.
- No saltarse la capa de errores explícitos.

---

> **Recordatorio:** cuanto más concreto y verificable sea este documento, mejor
> trabajará el agente y más fácil será para el `reviewer` rechazar lo que se
> desvíe.
