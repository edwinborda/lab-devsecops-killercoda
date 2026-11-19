# Herramientas y cluster Kubernetes

Revisa qué quedó instalado:

```
cd /root/lab && cat /root/setup.log
```{{exec}}

Crea el cluster de un nodo con **kind** (Kubernetes dentro de un contenedor Docker):

```
./scripts/01-crear-cluster.sh
```{{exec}}

El archivo `scripts/kind-config.yaml` publica los NodePort `30080`, `30090` y `30300` en la máquina, para que Killercoda los pueda abrir en el navegador.

Comprueba el nodo:

```
kubectl get nodes
```{{exec}}

> **Pregunta para discutir:** ¿qué diferencia hay entre este cluster y uno administrado como GKE o EKS?
