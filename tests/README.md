# tests/

Aquí van los **tests automáticos**. En el template está vacío a propósito.

- El `implementer` escribe un test por cada cambio de código (ver
  [`docs/verification.md`](../docs/verification.md)).
- Cada `R<n>` de un spec debe quedar cubierto por al menos un test concreto;
  el `reviewer` rechaza si falta cobertura.
- Configura el comando que ejecuta esta suite en
  [`harness.config`](../harness.config) (`TEST_CMD`). `init.sh` y los hooks lo
  usan automáticamente.

Borra este `README.md` cuando añadas tu primer test.
