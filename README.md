# FastAPI DevOps Challenge with GitHub Container Registry and Helm

This repository contains a containerized FastAPI application deployed to a local Kubernetes (Minikube) cluster using Helm, with CI/CD handled by GitHub Actions and GitHub Container Registry (GHCR).

---

## 📁 Project Structure

```
.
├── app-code/                # FastAPI application code and Dockerfile
├── helm/fastapi-app/        # Helm chart with deployment, service, ingress
└── .github/workflows/       # GitHub Actions CI/CD pipeline
```

---

## 🚀 How to Run Locally (Minikube)

### 1. Start Minikube and Enable Ingress
```bash
minikube start
minikube addons enable ingress
```

### 2. Add Ingress Host Mapping
```bash
echo "$(minikube ip) fastapi.local" | sudo tee -a /etc/hosts
```

### 3. Install Helm Chart
```bash
helm install fastapi-app ./helm/fastapi-app
```

### 4. Access the API
Open: [http://fastapi.local](http://fastapi.local)

---

## ⚙️ GitHub Actions CI/CD Pipeline

### Trigger:
- Automatically on push to `main`.

### Steps:
1. Build Docker image from `./app-code`
2. Push to `ghcr.io/<your-username>/fastapi-app:latest`
3. Use Helm to deploy the app on Kubernetes

---

## 🔐 GitHub Secrets Required

| Secret Name     | Description |
|------------------|-------------|
| `GITHUB_TOKEN`   | Built-in GitHub token for pushing to GHCR |
| `KUBECONFIG`     | Base64-encoded kubeconfig file for local Minikube |

To encode your kubeconfig:
```bash
cat ~/.kube/config | base64
```

---

## 🛠 FastAPI Example

The app responds at `/` with:

```json
{
  "message": "Hello, world!"
}
```

---

## 🐳 Build and Run Locally (Optional)

```bash
cd app-code
docker build -t fastapi-app .
docker run -d -p 8000:80 fastapi-app
```
Visit: http://localhost:8000

---

## 📦 Container Registry

This project uses **GitHub Container Registry (GHCR)**:

- Example image: `ghcr.io/<your-username>/fastapi-app:latest`

Update the repository and owner names in:
- `values.yaml`
- `.github/workflows/ci-cd.yml`

---

