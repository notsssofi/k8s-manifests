#!/bin/bash
set -euo pipefail

#---------------------------------------------------------------------------
#Nombre: Sofia Gutierrez
#Fecha: 28 de Abril, 2025
# Despliega una página web estática en Minikube con Kubernetes - TP 0311AT
#---------------------------------------------------------------------------

# - variables de configuración -
STATIC_REPO="https://github.com/notsssofi/static-website.git"
MANIFESTS_REPO="https://github.com/notsssofi/k8s-manifests.git"
STATIC_DIR="static-website"
MANIFESTS_DIR="k8s-manifests"
MOUNT_PATH="/mnt/web"
NODE_PORT=30080

# - función para validar las herramientas necesarias -
function check_dependencias() {
  for cmd in git kubectl minikube; do
    if ! command -v "$cmd" &> /dev/null; then
      echo "Error: $cmd no está instalado. Instalar primero"
      exit 1
    fi
  done
}

echo "Validando las herramientas necesarias"
check_dependencias

echo "Clonando repositorios solo si es necesario"

if [ ! -d "$STATIC_DIR" ]; then
  echo "Clono repositorio de la página web estática..."
  git clone "$STATIC_REPO"
else
  echo "El directorio $STATIC_DIR ya existe"
fi

if [ ! -d "$MANIFESTS_DIR" ]; then
  echo "Clono repositorio de manifiestos Kubernetes..."
  git clone "$MANIFESTS_REPO"
else
  echo "El directorio $MANIFESTS_DIR ya existe"
fi

# - verificar que static-website tenga adentro el index.html -
if [ ! -f "${STATIC_DIR}/index.html" ]; then
  echo "Error: No se encontró index.html en ${STATIC_DIR}"
  exit 1
fi

echo "Iniciando Minikube..."

if ! minikube status | grep -q "Running"; then
  minikube start --driver=docker --mount --mount-string="$(pwd)/${STATIC_DIR}:${MOUNT_PATH}"
else
  echo "Minikube ya está corriendo"
fi

echo "Aplicando los manifiestos"

cd "$MANIFESTS_DIR"

echo "Aplico el Persistent Volume"
kubectl apply -f pv/web-pv.yaml

echo "Aplico el Persistent Volume Claim"
kubectl apply -f pvc/web-pvc.yaml

echo "Aplico el Deployment"
kubectl apply -f deployments/web-deployment.yaml

echo "Aplico el Service"
kubectl apply -f services/web-service.yaml

cd ..

# - esperar a que el pod realmente esté Running -
echo "Esperando que el pod esté listo"

while true; do
  STATUS=$(kubectl get pods -l app=web -o jsonpath="{.items[0].status.phase}" 2>/dev/null || echo "NotFound")

  if [ "$STATUS" == "Running" ]; then
    echo "El pod ya está en estado Running."
    break
  fi

  echo "Todavía no está listo... Estado actual: $STATUS"
  sleep 2
done

# - mostrar IP -
MINIKUBE_IP=$(minikube ip)
echo "Entrar al sitio en: http://${MINIKUBE_IP}:${NODE_PORT}"

echo "Despliegue completado exitosamente!"

