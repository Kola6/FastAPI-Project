# Part 2 - Architecture of deployment and project structure

Here’s a comprehensive architecture design description that includes **code protection**, **CI/CD pipeline**, **cluster architecture**, and **deployment strategy**. 

---

## Repository Structure/Setup

my-app/
├── .github/
│   └── workflows/                  # GitHub Actions CI/CD workflows
├── app/
│   └── (source code)              # Actual application code
├── charts/
│   └── my-app/                    # Helm chart for K8s deployment
├── manifests/
│   ├── dev/                       # K8s manifests or ArgoCD app YAMLs for dev
│   ├── qa/                        # K8s manifests or ArgoCD app YAMLs for qa
│   └── prod/                      # K8s manifests or ArgoCD app YAMLs for prod
├── Dockerfile
├── terraform/
│   └── azure-infra/               # Infra as code - K8s, Key Vault etc.
├── sonar-project.properties
└── README.md

---

## Architecture Diagram 

The architecture diagram is shown below 
![architecture](./additional-files/images/img7.png).

---

## 🔐 Code Protection Measures

### 1. **Source Code Access Control**

* **Git Repository Hosting**: GitHub Enterprise with enforced **SSO authentication** and **RBAC (Role-Based Access Control)**.

* **Branch Protections**:

  * Enforce pull requests (PRs) for all changes to `main` branch.
  * Require code review approvals and successful CI checks before merging.
  * The CI checks could include Linter check, Sonarscan, BlackDuck scan and unity tests.
  * No direct commits allowed on `main` branch.

* **Audit Logs**:

  * Full audit trail for repository activities to track who did what and when.

### 2. **Secrets Management**

* No hard-coded secrets in source code.
* Use **Azure Key Vault** to manage environment secrets.
* Inject secrets at runtime using tools like **Sealed Secrets**, **Kubernetes Secrets**, or **CI/CD secret injection mechanisms**.
* Enable **CodeQL** in GitHub which scans for vulnerability and identifies hard code secrets.
* Enable **Secret Scanning (GitHub Advanced Security)** which checks for secret patterns like API keys, tokens etc. Alerts are raised which notifies the Owner and Administrator.

### 3. **Static Code Analysis & Security Scanning**

* Integrate tools like **SonarQube**, **Linter**, **CodeQL**, or **Blackduck** in the CI pipeline to catch:

  * Vulnerabilities (e.g., SQL injection, XSS)
  * Code smells
  * License violations
  * Scan Docker images for known CVEs. 

### 4. **Dependency Updates**

* Use tools like **Dependabot** to:

  * Automatically detect outdated or vulnerable packages.

---

## 🔄 CI/CD Pipeline Architecture

### 🧰 Tools & Technologies

* **Version Control**: GitHub
* **CI Engine**: GitHub Actions 
* **CD Platform**: ArgoCD
* **Container Registry**: Azure Container Registry (ACR)
* **IaC**: Terraform
* **Kubernetes Cluster**: Azure Kubernetes Service
* **Policy Enforcement Tool**: OPA Gatekeeper or Kyverno
* **Templating & Deployment files**: Helm
* **Monitoring & Logging**: New Relic
* **Notifications**: Slack
* **Secret Management**: Azure Key Vault & Github Secrets

### Developer Workflow

* A developer creates a `feature` branch on Github, develops and pushes code to it. 
* Once the development is done, a `Pull Request` is created.
* This Pull Request then checks for the checks configured (Sonarqube, Linter, Blackduck and unit tests). 
* When the checks are green and everything looks okay, developer requests a review from a Reviewer and assigns on the Pull Request. 
* The `Reviewer` then reviews the Pull Request. If everything is fine, then provides approval else rejects and requests changes or leaves comments on the Pull Request.
* Once the Pull Request is approved, it is then manually merged into `main` branch.
* Pull Request merged automatically triggers the CI pipeline for Dev & QA environment. 
* Incase the Pull request is rejected, the developer reworks and sends for approval again.
* Developers can create multiple feature branches and Pull requests for their development work independently.

### 🔧 Continuous Integration (CI) Steps

1. **Setup**

   * Here code is checked out to fetch code from a specific branch. 
   * It also contains `detect changes` actions from Github Marketplace which is used to identify changes in files and directories in the repository.

2. **Build**

   * Compile code / build docker image & push to Azure container registry.

3. **Update Helm**

   * The relevant helm values file is updated for docker image tag for respective environment. For eg. For dev, values-dev.yaml file.

### 🚀 Continuous Delivery/Deployment (CD) Steps

1. **Pull from GitOps Repo**

   * ArgoCD watches a Git repo for desired state changes and performs sync.

2. **Apply K8s Manifests created using Helm Charts**

   * Deploy to target environment

3. **Post-deploy Steps**

   * Run smoke tests for Dev and regression tests for QA environments respectively. 
   * Health checks via readiness/liveness probes configured in Helm charts.
   * Once the sync is performed, notifications are send to slack channel.
 
---

## ☁️ Cluster Architecture & Environment Separation

### 1. **Kubernetes Cluster Architecture**

#### Platform:

* **Managed K8s** (e.g., Azure AKS)

#### Nodes:

* **Node Pools**:

  * General workloads
  * High-memory jobs
  * GPU workloads (if ML is involved)

#### Namespaces per Environment:

* `dev`, `staging or QA`, `prod`
* **RBAC** per namespace
* **Resource quotas** to limit compute usage

#### Networking:

* **Service Mesh**: Istio for secure intra-cluster communication
* **Ingress Controller**: NGINX or AWS ALB Ingress for routing
* **Cert Manager**: Certificates obtained from issuers (eg. Digicert) for applications which ensure they are valid and up-to-update.
* **Kyverno**: Policy enforcement tool for k8s that defines and enforces rules for deployments and resources to be created in the cluster.

#### Clusters:

* **Number of clusters**: Two clusters used where one cluster contains Dev and QA namespace and the other cluster is only for Prod. Production Cluster will usually have a different configuration eg. increased replicasets, highly availability, Autoscaling enabled etc. 

---

### 2. **Environment Separation**

| Environment | Description                                                                            |
| ----------- | -------------------------------------------------------------------------------------- |
| `dev`       | For developers. Auto-deployed. Lower resource limits.            |
| `staging or qa`   | Mirrors prod. Auto-deployed. Used by QA team.                    |
| `prod`      | Stable environment. Manual approval. Monitored tightly. |

---

## 🚢 Deployment Strategy

### 1. **Release Workflow Diagram**

Shown below:
![Release Flow](./additional-files/images/img8.png)


### 2. **Release Deployment Process**

### 3. **Failure Recovery**

* **Rollback support** via GitOps (ArgoCD tracks Git as source of truth)
* **Readiness/liveness probes** for pod health

### 3. **Monitoring & Logging**

---
