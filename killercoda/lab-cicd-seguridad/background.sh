#!/bin/bash
# Se ejecuta en segundo plano al abrir el escenario: clona el repo y prepara herramientas.
REPO_URL="https://github.com/mafeopa/lab-devsecops-killercoda.git"

cd /root
git clone "$REPO_URL" lab >/root/clone.log 2>&1
chmod +x /root/lab/scripts/*.sh
bash /root/lab/scripts/00-instalar-herramientas.sh >/root/setup.log 2>&1
# Descarga anticipada de imágenes pesadas para ahorrar tiempo en clase
docker pull -q sonarqube:10.7-community >/dev/null 2>&1 &
docker pull -q kindest/node:v1.31.0 >/dev/null 2>&1 &
wait
touch /tmp/.setup-listo
