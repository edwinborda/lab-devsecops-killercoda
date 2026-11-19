# Lab DevSecOps — CI/CD con SonarQube, Trivy y Kubernetes

Laboratorio interactivo para **Fundamentos DevOps** (Universidad de La Sabana).
Un microservicio de dos capas —**frontend** (Nginx) y **backend** (Node.js/Express)— que recorre todas las etapas de un pipeline CI/CD con seguridad integrada, ejecutable en **Killercoda** sin instalar nada en el equipo del estudiante.

## Arquitectura

```
Navegador ──► frontend (Nginx :8080, NodePort 30080)
                 │  /api/*
                 ▼
              backend (Node.js :3000) ──► /metrics ──► Prometheus ──► Grafana
                 (namespace: tareas)                  (namespace: monitoreo)
```

## Pipeline que se practica

```
pruebas → SonarQube → build de imágenes → Trivy (quality gate) → push → despliegue K8s → smoke test
```

| Archivo | Rol |
|---|---|
| `.github/workflows/ci.yml` | CI en GitHub Actions: pruebas, SonarQube, Trivy (fs, imagen, SARIF), quality gate |
| `Jenkinsfile` | CD en Jenkins: pruebas, Sonar, build, Trivy, push, `kubectl`, smoke test y rollback |
| `k8s/` | Namespace, Deployments y Services (probes, recursos, usuario no root) |
| `k8s/monitoring/` | Prometheus + Grafana livianos con reglas de alerta |
| `scripts/` | Pasos numerados para ejecutar el laboratorio en Killercoda |
| `killercoda/` | Escenario guiado para publicar en Killercoda |

## Hallazgos intencionales (para discutir en clase)

| Hallazgo | Dónde | Lo detecta |
|---|---|---|
| `lodash 4.17.15` con CVE conocidas | `backend/package.json` | Trivy (`fs` e `image`) |
| Contraseña quemada `ADMIN_PASSWORD` | `backend/src/app.js` | SonarQube (Security Hotspot) |

## Ejecución rápida en Killercoda (playground Ubuntu)

```bash
git clone https://github.com/mafeopa/lab-devsecops-killercoda.git lab && cd lab
chmod +x scripts/*.sh
./scripts/00-instalar-herramientas.sh   # kind, kubectl, Trivy, sysctl para SonarQube
./scripts/01-crear-cluster.sh           # cluster Kubernetes con kind
./scripts/02-sonarqube.sh               # SonarQube + análisis       → puerto 9000
./scripts/03-build-y-escaneo.sh         # pruebas, imágenes y Trivy
./scripts/04-desplegar.sh               # despliegue en K8s          → puerto 30080
./scripts/05-monitoreo.sh               # (opcional) Prometheus 30090 / Grafana 30300
./scripts/verificar.sh                  # checklist final
```

Los puertos se abren desde el menú **☰ → Traffic / Ports** de Killercoda.

## Ejecución local

Requiere Docker. Los mismos scripts funcionan en Linux o WSL2 (ejecutar con `sudo` los pasos 0 y 2 por `sysctl`).

## Credenciales del laboratorio

| Servicio | Usuario | Contraseña |
|---|---|---|
| SonarQube | admin | `DevOps2026!lab` |
| Grafana | admin | `devops2026` |

Son credenciales de un entorno efímero de práctica; nunca reutilizarlas fuera del laboratorio.
