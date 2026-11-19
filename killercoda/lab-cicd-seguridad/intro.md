# Laboratorio DevSecOps

En este laboratorio vas a recorrer, en tu propio entorno, las etapas que automatiza un pipeline CI/CD con seguridad integrada:

| Etapa | Herramienta | Qué demuestra |
|---|---|---|
| Plataforma | **kind** | Crear un cluster Kubernetes desde cero |
| Calidad | **SonarQube** | Análisis estático: bugs, code smells y *security hotspots* |
| Seguridad | **Trivy** | Vulnerabilidades en dependencias, imágenes y configuración |
| Despliegue | **kubectl** | Frontend (Nginx) + backend (Node.js) en Kubernetes |
| Observabilidad | **Prometheus / Grafana** | Métricas del backend (opcional) |

La aplicación es un **tablero de tareas**: el frontend llama a `/api/*` y Nginx lo reenvía al Service `backend` del cluster.

Mientras lees, el entorno está clonando el repositorio e instalando las herramientas. Cuando la terminal muestre **"Entorno listo"**, continúa.
