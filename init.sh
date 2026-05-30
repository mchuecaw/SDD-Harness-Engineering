#!/usr/bin/env bash
# init.sh — Verificación e inicialización del arnés
#
# Este script lo ejecuta el agente al COMENZAR una sesión y antes de declarar
# cualquier tarea como `done`. Si falla, la sesión no debe avanzar.
#
# Es AGNÓSTICO DE LENGUAJE: la única parte específica de tu stack es el
# comando de tests, que se configura en `harness.config` (TEST_CMD).
#
# Salida esperada: códigos de salida claros y bloques marcados [OK]/[WARN]/[FAIL].

set -u

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

ok()    { printf "${GREEN}[OK]${NC}    %s\n" "$1"; }
warn()  { printf "${YELLOW}[WARN]${NC}  %s\n" "$1"; }
fail()  { printf "${RED}[FAIL]${NC}  %s\n" "$1"; }

EXIT_CODE=0

# Cargar configuración del proyecto (TEST_CMD, etc.)
TEST_CMD=""
TEST_COUNT_CMD=""
if [ -f "harness.config" ]; then
  # shellcheck disable=SC1091
  . ./harness.config
fi

echo "── 1. Verificando archivos base del arnés ──────────────"

BASE_FILES="AGENTS.md CLAUDE.md feature_list.json harness.config progress/current.md \
docs/methodology.md docs/harness-engineering.md docs/specs.md \
docs/architecture.md docs/conventions.md docs/verification.md CHECKPOINTS.md"

for f in $BASE_FILES; do
  if [ ! -f "$f" ]; then
    fail "Falta archivo base: $f"
    EXIT_CODE=1
  else
    ok "Existe $f"
  fi
done

echo ""
echo "── 2. Validando feature_list.json y specs ─────────────"

if command -v python3 >/dev/null 2>&1; then
  python3 - <<'PY'
import json, os, sys
try:
    data = json.load(open("feature_list.json"))
    valid = {"pending", "spec_ready", "in_progress", "done", "blocked"}
    features = data.get("features", [])
    in_progress = [f for f in features if f.get("status") == "in_progress"]
    if len(in_progress) > 1:
        print(f"[FAIL]  Hay {len(in_progress)} features en in_progress (máximo 1)")
        sys.exit(1)
    requires_spec = {"spec_ready", "in_progress", "done"}
    spec_errors = []
    for f in features:
        if f.get("status") not in valid:
            print(f"[FAIL]  Estado inválido en feature {f.get('id')}: {f.get('status')}")
            sys.exit(1)
        if f.get("sdd") and f.get("status") in requires_spec:
            spec_dir = os.path.join("specs", f["name"])
            for fname in ("requirements.md", "design.md", "tasks.md"):
                if not os.path.isfile(os.path.join(spec_dir, fname)):
                    spec_errors.append(
                        f"feature {f.get('id')} ({f.get('name')}) en {f.get('status')} "
                        f"sin {spec_dir}/{fname}"
                    )
    if spec_errors:
        for e in spec_errors:
            print(f"[FAIL]  {e}")
        sys.exit(1)
    print(f"[OK]    feature_list.json válido ({len(features)} features)")
    print("[OK]    Specs presentes para features sdd con estado no-pending")
except SystemExit:
    raise
except Exception as e:
    print(f"[FAIL]  feature_list.json o specs inválidos: {e}")
    sys.exit(1)
PY
  if [ $? -ne 0 ]; then EXIT_CODE=1; fi
else
  warn "python3 no disponible: se omite la validación de invariantes del arnés."
  warn "Instala python3 (solo se usa como tooling del arnés) para validar feature_list.json y specs."
fi

echo ""
echo "── 3. Ejecutando tests del proyecto ────────────────────"

if [ -n "${TEST_CMD}" ]; then
  echo "    \$ ${TEST_CMD}"
  if eval "${TEST_CMD}"; then
    ok "Todos los tests pasan"
  else
    fail "Hay tests rotos"
    EXIT_CODE=1
  fi
else
  warn "TEST_CMD no configurado en harness.config — sin tests que ejecutar todavía."
  warn "Configúralo en cuanto tengas tu primer test (ver harness.config)."
fi

echo ""
echo "── 4. Resumen ──────────────────────────────────────────"

if [ $EXIT_CODE -eq 0 ]; then
  ok "Entorno listo. Puedes empezar a trabajar."
else
  fail "Entorno NO está listo. Resuelve los errores antes de avanzar."
fi

exit $EXIT_CODE
