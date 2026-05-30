# ADR-0007 -- Las apps moviles myWallbox usan MVVM + capa de dominio

> EJEMPLO ILUSTRATIVO de ADR FUNDACIONAL (Scope de stack). No es una decision
> real de la empresa. Vive en examples/ a proposito: init.sh no lo valida.

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
