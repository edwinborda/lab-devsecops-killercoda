# Calidad de código con SonarQube

Levanta SonarQube Community, genera un token y analiza el proyecto:

```
./scripts/02-sonarqube.sh
```{{exec}}

Abre la consola de SonarQube: [SonarQube :9000]({{TRAFFIC_HOST1_9000}})

- Usuario: `admin` · Contraseña: `DevOps2026!lab`
- Proyecto: **tasks-app**

Busca en **Security Hotspots** la credencial quemada en `backend/src/app.js` (`ADMIN_PASSWORD`). Se dejó a propósito.

> **Pregunta para discutir:** ¿por qué SonarQube lo marca como *hotspot* y no como vulnerabilidad confirmada? ¿Cómo lo resolverías con un Secret de Kubernetes?
