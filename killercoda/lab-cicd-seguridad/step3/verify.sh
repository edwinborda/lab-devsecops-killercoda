#!/bin/bash
docker image inspect tasks-backend:1.0.0 >/dev/null 2>&1 && \
docker image inspect tasks-frontend:1.0.0 >/dev/null 2>&1 && \
[ -s /root/lab/reportes/trivy-backend.txt ]
