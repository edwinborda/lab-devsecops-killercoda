# Despliegue en Kubernetes

Carga las imágenes en el nodo y aplica los manifiestos:

```
./scripts/04-desplegar.sh
```{{exec}}

Abre la aplicación: [Tablero de tareas :30080]({{TRAFFIC_HOST1_30080}})

Agrega una tarea y márcala como hecha. Luego observa el balanceo entre réplicas:

```
kubectl -n tareas get pods -o wide
kubectl -n tareas logs deploy/backend --tail=5
```{{exec}}

Prueba la autorrecuperación borrando un pod del backend:

```
kubectl -n tareas delete pod -l app=backend --wait=false | head -1
kubectl -n tareas get pods -w
```{{exec}}

(Presiona `Ctrl+C` para salir del modo *watch*.)

> **Pregunta para discutir:** ¿qué papel cumplen `readinessProbe` y `livenessProbe` en ese reemplazo?
