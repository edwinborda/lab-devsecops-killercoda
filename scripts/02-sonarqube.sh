#!/usr/bin/env bash
# Paso 2 — Levanta SonarQube Community, crea un token y analiza el backend.
set -euo pipefail
cd "$(dirname "$0")/.."

SONAR_URL="http://localhost:9000"
NEW_PASS="${SONAR_PASS:-DevOps2026!lab}"

if ! docker ps --format '{{.Names}}' | grep -qx sonarqube; then
  echo "==> Iniciando SonarQube (la primera vez tarda 2–3 minutos)"
  docker rm -f sonarqube >/dev/null 2>&1 || true
  docker run -d --name sonarqube -p 9000:9000 \
    -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
    sonarqube:10.7-community >/dev/null
fi

echo -n "==> Esperando a que SonarQube esté UP "
for i in $(seq 1 60); do
  STATUS=$(curl -s "${SONAR_URL}/api/system/status" | sed -n 's/.*"status":"\([A-Z_]*\)".*/\1/p')
  [ "$STATUS" = "UP" ] && break
  echo -n "."; sleep 5
done
echo " ${STATUS:-desconocido}"
[ "$STATUS" = "UP" ] || { echo "SonarQube no arrancó; revisa: docker logs sonarqube"; exit 1; }

# Cambia la contraseña por defecto (admin/admin) la primera vez
curl -s -o /dev/null -u admin:admin -X POST \
  "${SONAR_URL}/api/users/change_password?login=admin&previousPassword=admin&password=${NEW_PASS}" || true

echo "==> Generando token de análisis"
TOKEN=$(curl -s -u "admin:${NEW_PASS}" -X POST \
  "${SONAR_URL}/api/user_tokens/generate?name=lab-$(date +%s)&type=GLOBAL_ANALYSIS_TOKEN" \
  | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
[ -n "$TOKEN" ] || { echo "No se pudo generar el token"; exit 1; }
echo "$TOKEN" > .sonar-token

echo "==> Ejecutando sonar-scanner sobre el proyecto"
docker run --rm --network host \
  -v "$(pwd):/usr/src" \
  -e SONAR_HOST_URL="${SONAR_URL}" \
  -e SONAR_TOKEN="${TOKEN}" \
  sonarsource/sonar-scanner-cli:11

echo
echo "Análisis enviado. Usuario: admin  Contraseña: ${NEW_PASS}"
echo "Abre el puerto 9000 desde el menú Traffic/Ports de Killercoda → proyecto 'tasks-app'."
