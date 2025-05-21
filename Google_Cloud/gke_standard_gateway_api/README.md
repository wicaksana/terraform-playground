# GKE with Gateway API 

```bash
terraform init
terraform apply
kubectl apply -f https://raw.githubusercontent.com/wicaksana/go-simple-microservices/refs/heads/main/k8s/00_namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/wicaksana/go-simple-microservices/refs/heads/main/k8s/01_postgres_storage.yaml
kubectl apply -f https://raw.githubusercontent.com/wicaksana/go-simple-microservices/refs/heads/main/k8s/02_postgres_credentials.yaml
kubectl apply -f https://raw.githubusercontent.com/wicaksana/go-simple-microservices/refs/heads/main/k8s/03_postgres_deployment.yaml
kubectl apply -f https://raw.githubusercontent.com/wicaksana/go-simple-microservices/refs/heads/main/k8s/04_postgres_service.yaml
kubectl apply -f https://raw.githubusercontent.com/wicaksana/go-simple-microservices/refs/heads/main/k8s/05_backend-deployment.yaml
kubectl apply -f https://raw.githubusercontent.com/wicaksana/go-simple-microservices/refs/heads/main/k8s/06_backend-service.yaml
kubectl apply -f https://raw.githubusercontent.com/wicaksana/go-simple-microservices/refs/heads/main/k8s/07_frontend-deployment.yaml
kubectl apply -f https://raw.githubusercontent.com/wicaksana/go-simple-microservices/refs/heads/main/k8s/08_frontend-service.yaml
kubectl apply -f https://raw.githubusercontent.com/wicaksana/go-simple-microservices/refs/heads/main/k8s/09_secret.yaml
kubectl apply -f https://raw.githubusercontent.com/wicaksana/go-simple-microservices/refs/heads/main/k8s/10_gateway.yaml
```