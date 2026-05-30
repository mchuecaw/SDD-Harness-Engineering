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

> EJEMPLO ILUSTRATIVO de skill. No esta publicado (vive en examples/, no en
> .claude/skills/, y no tiene entrada en skills/registry.json).

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
