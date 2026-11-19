#!/usr/bin/env bash
# Paso 0 — Instala kind, kubectl y Trivy, y prepara el kernel para SonarQube.
set -euo pipefail

KIND_VERSION="v0.24.0"
KUBECTL_VERSION="v1.31.2"

echo "==> Verificando Docker"
docker version --format 'Docker {{.Server.Version}}'

if ! command -v kind >/dev/null; then
  echo "==> Instalando kind ${KIND_VERSION}"
  curl -sSLo /usr/local/bin/kind "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64"
  chmod +x /usr/local/bin/kind
fi

if ! command -v kubectl >/dev/null; then
  echo "==> Instalando kubectl ${KUBECTL_VERSION}"
  curl -sSLo /usr/local/bin/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
  chmod +x /usr/local/bin/kubectl
fi

if ! command -v trivy >/dev/null; then
  echo "==> Instalando Trivy"
  curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
fi

echo "==> Ajustando vm.max_map_count para SonarQube (Elasticsearch embebido)"
sysctl -w vm.max_map_count=524288 >/dev/null
sysctl -w fs.file-max=131072 >/dev/null

echo
echo "Versiones instaladas:"
kind version
kubectl version --client | head -1
trivy --version | head -1
free -h | awk 'NR<=2'
