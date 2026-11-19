#!/usr/bin/env bash
# Paso 4 — Carga las imágenes en el cluster y despliega frontend + backend.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> Cargando imágenes locales en el nodo de kind"
kind load docker-image tasks-backend:1.0.0  --name lab
kind load docker-image tasks-frontend:1.0.0 --name lab

echo "==> Aplicando manifiestos"
kubectl apply -f k8s/00-namespace.yaml
kubectl apply -f k8s/10-backend.yaml
kubectl -n tareas rollout status deploy/backend --timeout=120s
kubectl apply -f k8s/20-frontend.yaml
kubectl -n tareas rollout status deploy/frontend --timeout=120s

kubectl -n tareas get pods,svc -o wide
echo
echo "Prueba local:"
curl -s http://localhost:30080/api/health; echo
echo "Abre el puerto 30080 desde Traffic/Ports de Killercoda para ver el tablero."
