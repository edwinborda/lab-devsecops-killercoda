#!/usr/bin/env bash
# Paso 3 — Pruebas, construcción de imágenes y escaneo de seguridad con Trivy.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p reportes

echo "==> Pruebas unitarias del backend (en contenedor Node 20)"
docker run --rm -v "$(pwd)/backend:/app" -w /app node:20-alpine \
  sh -c "npm ci --no-audit --no-fund && npm test"

echo "==> Trivy: dependencias del código fuente (SCA)"
trivy fs --scanners vuln --severity HIGH,CRITICAL --format table backend/ | tee reportes/trivy-fs.txt

echo "==> Trivy: configuración de Dockerfiles y manifiestos (IaC)"
trivy config --severity HIGH,CRITICAL . | tee reportes/trivy-config.txt

echo "==> Construyendo imágenes"
docker build -t tasks-backend:1.0.0 backend/
docker build -t tasks-frontend:1.0.0 frontend/

echo "==> Trivy: imágenes de contenedor"
trivy image --severity HIGH,CRITICAL --format table tasks-backend:1.0.0  | tee reportes/trivy-backend.txt
trivy image --severity HIGH,CRITICAL --format table tasks-frontend:1.0.0 | tee reportes/trivy-frontend.txt

echo
echo "==> Quality gate de seguridad (falla si hay CRITICAL en el backend)"
if trivy image --quiet --severity CRITICAL --exit-code 1 tasks-backend:1.0.0 >/dev/null; then
  echo "OK: sin vulnerabilidades CRITICAL"
else
  echo "ATENCIÓN: la imagen del backend tiene vulnerabilidades CRITICAL (ver reportes/trivy-backend.txt)"
  echo "En un pipeline real este paso detendría el despliegue."
fi
