# Imágenes y escaneo con Trivy

Ejecuta pruebas unitarias, construye las dos imágenes y escanéalas:

```
./scripts/03-build-y-escaneo.sh
```{{exec}}

Trivy revisa tres capas:

1. `trivy fs` — dependencias declaradas en `package-lock.json` (SCA)
2. `trivy config` — Dockerfiles y manifiestos de Kubernetes (IaC)
3. `trivy image` — paquetes del sistema operativo y librerías dentro de cada imagen

Mira el reporte del backend:

```
grep -E "lodash|Total" reportes/trivy-fs.txt
```{{exec}}

El backend usa `lodash 4.17.15` a propósito. **Corrígelo** y vuelve a escanear:

```
sed -i 's/"lodash": "4.17.15"/"lodash": "4.17.21"/' backend/package.json
docker run --rm -v "$PWD/backend:/app" -w /app node:20-alpine npm install --package-lock-only --no-audit --no-fund
trivy fs --scanners vuln --severity HIGH,CRITICAL backend/
```{{exec}}

> **Pregunta para discutir:** ¿en qué etapa del pipeline pondrías el *quality gate* de Trivy y con qué severidad?
