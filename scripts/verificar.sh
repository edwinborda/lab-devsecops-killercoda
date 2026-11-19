#!/usr/bin/env bash
# Comprueba el estado de cada pieza del laboratorio.
cd "$(dirname "$0")/.."
ok()   { echo "  [OK]  $1"; }
fail() { echo "  [--]  $1"; }

echo "Verificación del laboratorio"
command -v trivy  >/dev/null && ok "Trivy instalado"   || fail "Trivy no instalado (paso 0)"
command -v kind   >/dev/null && ok "kind instalado"    || fail "kind no instalado (paso 0)"
kubectl get nodes 2>/dev/null | grep -q " Ready" && ok "Cluster Kubernetes Ready" || fail "Cluster no disponible (paso 1)"
curl -s localhost:9000/api/system/status | grep -q '"UP"' && ok "SonarQube UP" || fail "SonarQube no responde (paso 2)"
[ -s .sonar-token ] && ok "Análisis SonarQube ejecutado" || fail "Sin análisis SonarQube (paso 2)"
ls reportes/trivy-backend.txt >/dev/null 2>&1 && ok "Reportes Trivy generados" || fail "Sin reportes Trivy (paso 3)"
kubectl -n tareas get deploy backend frontend >/dev/null 2>&1 && ok "Frontend y backend desplegados" || fail "App no desplegada (paso 4)"
curl -s localhost:30080/api/health | grep -q '"ok"' && ok "App responde en :30080" || fail "La app no responde en :30080"
curl -s localhost:30090/-/ready 2>/dev/null | grep -qi ready && ok "Prometheus listo (opcional)" || fail "Prometheus no desplegado (opcional, paso 5)"
