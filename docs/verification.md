# Verificación — Cómo demostrar que el trabajo funciona

> Regla de oro: **el agente no dice "funciona", lo demuestra**.
> Toda feature termina con evidencia ejecutable, no con afirmaciones.

## Niveles de verificación

### Nivel 1 — Tests unitarios (obligatorio)

Toda función / unidad pública en `src/` tiene al menos un test en `tests/` que:

1. Cubre el camino feliz.
2. Cubre al menos un camino de error si la unidad puede fallar.

El comando que ejecuta la suite es el `TEST_CMD` de `harness.config`. `init.sh`
lo invoca por ti.

### Nivel 2 — Test de integración (obligatorio para features de interfaz)

Las features que añaden comportamiento observable desde fuera (un endpoint, un
comando, una pantalla) se verifican ejercitando la interfaz real contra un
entorno aislado (un directorio temporal, una base de datos efímera, un cliente
HTTP de test), no solo llamando funciones internas.

> Adapta el mecanismo a tu stack: `subprocess` contra un binario, un test
> client HTTP, un runner de CLI, etc. Lo importante es que se ejercite el
> camino completo que verá el usuario.

### Nivel 3 — Smoke test manual (opcional pero recomendado)

Antes de cerrar la sesión, ejecuta un flujo end-to-end real contra un entorno
desechable y comprueba el resultado con tus ojos. Documenta los comandos en
`progress/impl_<name>.md` para que sean reproducibles.

### Nivel 4 — Trazabilidad de requirements (obligatorio para features `"sdd": true`)

Cada `R<n>` de `specs/<name>/requirements.md` debe poder mapearse a al menos un
test concreto en `tests/`. El reviewer rechaza si falta cobertura.

El implementer documenta el mapa en `progress/impl_<name>.md`:

```markdown
## Trazabilidad
- R1 → `test_camino_feliz`
- R2 → `test_camino_error`
- R3 → `test_caso_borde`
```

## Anti-patrones (no hacer)

- ❌ "He añadido la feature, debería funcionar." → falta test ejecutable.
- ❌ Test que solo verifica que la función no lanza excepción. → tiene que
  comprobar el resultado concreto.
- ❌ Mockear el filesystem / la red cuando puedes usar un entorno real
  aislado y desechable.
- ❌ Marcar la feature como `done` sin pasar `./init.sh`.

## Verificación final antes de cerrar

```bash
./init.sh        # debe terminar con [OK] Entorno listo
```

Si `./init.sh` está rojo, **no** marques nada como `done`. Anota el bloqueo en
`progress/current.md` con estado `blocked` en `feature_list.json`.
