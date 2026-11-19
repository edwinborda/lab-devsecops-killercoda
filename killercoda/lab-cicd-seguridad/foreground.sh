#!/bin/bash
echo "Preparando el entorno del laboratorio (2–4 minutos)..."
while [ ! -f /tmp/.setup-listo ]; do sleep 3; echo -n "."; done
echo
echo "Entorno listo. Repositorio en /root/lab"
cd /root/lab
