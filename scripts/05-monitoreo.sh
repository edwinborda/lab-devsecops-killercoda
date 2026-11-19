#!/usr/bin/env bash
# Paso 5 (opcional) — Prometheus + Grafana dentro del cluster y tráfico de prueba.
set -euo pipefail
cd "$(dirname "$0")/.."

kubectl apply -f k8s/monitoring/prometheus-grafana.yaml
kubectl -n monitoreo rollout status deploy/prometheus --timeout=180s
kubectl -n monitoreo rollout status deploy/grafana --timeout=180s

echo "==> Generando tráfico (incluye algunos 400 intencionales)"
for i in $(seq 1 60); do
  curl -s -o /dev/null http://localhost:30080/api/tasks
  curl -s -o /dev/null -X POST -H 'Content-Type: application/json' -d '{}' http://localhost:30080/api/tasks
done

echo
echo "Prometheus → puerto 30090   (consulta: sum by (status) (rate(http_requests_total[1m])))"
echo "Grafana    → puerto 30300   (admin / devops2026)"
