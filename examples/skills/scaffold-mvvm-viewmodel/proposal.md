# Propuesta de skill -- scaffold-mvvm-viewmodel

> EJEMPLO ILUSTRATIVO. Acompana a SKILL.md para mostrar el formato de propuesta.

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
