# 🚀 Website en Kubernetes con Minikube

Este proyecto, realizado por **Sofía Gutierrez**, despliega una página web estática personalizada dentro de un entorno Kubernetes local utilizando **Minikube**. La página se sirve con un contenedor `nginx` y los archivos están almacenados de forma persistente usando volúmenes (`PersistentVolume` y `PersistentVolumeClaim`) montados desde el sistema de archivos local.

---

## 🛠️ Requisitos

- Docker
- Minikube
- kubectl
- Git
---

## 📁 Estructura del repositorio
k8s-manifests/ ├── deployments/ │ └── web-deployment.yaml ├── pv/ │ └── web-pv.yaml ├── pvc/ │ └── web-pvc.yaml └── services/ └── web-service.yaml

- `pv/`: Definición del volumen persistente con `hostPath`
- `pvc/`: Reclamo del volumen usado por el contenedor
- `deployments/`: Despliegue de la app con imagen de `nginx`
- `services/`: Servicio tipo `NodePort` para exponer la web localmente

---

## 🔧 Pasos para ejecutar el entorno

1. 
git clone https://github.com/notsssofi/static-website.git
git clone https://github.com/notsssofi/k8s-manifests.git

2. Iniciar Minikube con montaje de carpeta local
	
	minikube start --driver=docker --mount --mount-string="$(pwd)/static-website:/mnt/web"

	⚠️ Asegurate de reemplazar la ruta si estás fuera del directorio que contiene la carpeta static-website.

3. Aplicar los manifiestos

	kubectl apply -f pv/web-pv.yaml
	kubectl apply -f pvc/web-pvc.yaml
	kubectl apply -f deployments/web-deployment.yaml
	kubectl apply -f services/web-service.yaml

4. Acceder al sitio web

	Obtené la IP de Minikube con el comando: minikube ip

	Abrí en el navegador: http://<minikube-ip>:30080 

🧪 Verificación

	Verificar que el pod esté corriendo: kubectl get pods

	Comprobar que el volumen tenga contenido montado correctamente: kubectl exec -it <nombre-del-pod> -- ls /usr/share/nginx/html

🧠 Autor
	Sofía Gutierrez – Trabajo práctico 0311AT – "K8S: Casi como en producción"
