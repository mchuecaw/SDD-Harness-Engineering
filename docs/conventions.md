# Convenciones de código

> **PLANTILLA.** Homogeneidad extrema: la IA predice mejor cuando el
> repositorio se parece a sí mismo en todas partes. Reemplaza lo de abajo por
> las convenciones reales de tu stack. Mantén este archivo corto y tajante.

## Lenguaje y formato

- **Lenguaje / versión:** _REEMPLAZA (ej. Python 3.11, TypeScript 5.x, Go 1.22)_
- **Formato:** _REEMPLAZA (ej. PEP 8 / Prettier / gofmt). Longitud máx. de línea: ____
- **Linter / formateador:** _REEMPLAZA (ej. ruff, eslint, golangci-lint) — y si
  corre en `init.sh` o en un hook._
- **Imports / módulos:** _REEMPLAZA tu convención de orden y agrupación._
- **Strings:** _REEMPLAZA (comillas, interpolación preferida)._

## Nombres

| Tipo                    | Convención        | Ejemplo            |
|-------------------------|-------------------|--------------------|
| Módulos / archivos      | _REEMPLAZA_       | _..._              |
| Tipos / clases          | _REEMPLAZA_       | _..._              |
| Funciones / variables   | _REEMPLAZA_       | _..._              |
| Constantes              | _REEMPLAZA_       | _..._              |
| Privados                | _REEMPLAZA_       | _..._              |

## Estructura de archivo

> Define el "esqueleto" estándar de un archivo de código (cabecera, orden de
> secciones, docstring del módulo, etc.) para que todos se parezcan.

## Manejo de errores

> Define el patrón único de errores del proyecto (tipos de excepción base,
> jerarquía, cómo se propagan hasta la frontera, qué ve el usuario). Ejemplo de
> la forma esperada:

```
ErrorBase            # raíz de los errores del dominio
 └─ RecursoNoEncontrado
 └─ EntradaInvalida
```

La capa de interfaz captura los errores del dominio, emite un mensaje claro y
sale con código de error. Nunca propaga stack traces crudos al usuario.

## Tests

- _REEMPLAZA: un archivo de test por unidad / convención de nombres._
- _REEMPLAZA: aislamiento (directorios temporales reales en vez de mocks de IO)._
- Nombres de test descriptivos que digan qué comportamiento verifican.

## Comentarios

Por defecto **no** se escriben. Solo se permiten cuando explican un *porqué* no
obvio (workaround documentado, invariante sutil). Los nombres deben hacer el
resto.
