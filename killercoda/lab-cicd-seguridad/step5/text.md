# Monitoreo (opcional)

Despliega Prometheus y Grafana dentro del cluster y genera tráfico:

```
./scripts/05-monitoreo.sh
```{{exec}}

- [Prometheus :30090]({{TRAFFIC_HOST1_30090}}) — prueba la consulta `sum by (status) (rate(http_requests_total[1m]))`
- [Grafana :30300]({{TRAFFIC_HOST1_30300}}) — `admin` / `devops2026`, datasource Prometheus ya configurado

Revisa las reglas de alerta en **Prometheus → Alerts** (`BackendCaido`, `TasaErrores5xxAlta`).

Verificación final:

```
./scripts/verificar.sh
```{{exec}}
