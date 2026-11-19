# ¡Laboratorio completado!

Recorriste manualmente lo que el pipeline automatiza:

```
pruebas → SonarQube → build → Trivy (quality gate) → push → kubectl apply → smoke test
```

Ese mismo flujo está definido en el repositorio:

- `.github/workflows/ci.yml` — CI en GitHub Actions (pruebas, SonarQube, Trivy con SARIF)
- `Jenkinsfile` — CD en Jenkins (build, escaneo, publicación y despliegue con rollback)

**Para tu entrega:** haz *fork* del repositorio, activa GitHub Actions y adjunta las capturas de SonarQube, Trivy, el tablero desplegado y la ejecución del pipeline.
