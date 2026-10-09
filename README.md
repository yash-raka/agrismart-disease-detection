# AgriSmart Disease Detection 🌱

> A production-grade, cloud-native potato disease classification platform — built from the ground up with modern DevOps, Kubernetes orchestration, and AWS infrastructure.

![Tech Stack](https://img.shields.io/badge/AWS-Bedrock%20%7C%20S3%20%7C%20DynamoDB%20%7C%20Cognito-orange?logo=amazonaws)
![Docker](https://img.shields.io/badge/Docker-Containerized-blue?logo=docker)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestrated-blue?logo=kubernetes)
![FastAPI](https://img.shields.io/badge/Backend-FastAPI-green?logo=fastapi)
![React](https://img.shields.io/badge/Frontend-React-61DAFB?logo=react)
![TensorFlow](https://img.shields.io/badge/ML-TensorFlow-orange?logo=tensorflow)

---

## 🚀 Overview

AgriSmart is an end-to-end ML platform that helps farmers identify potato leaf conditions in real-time. By uploading an image, the system utilizes a Convolutional Neural Network (CNN) to instantly diagnose the plant, while leveraging Generative AI to provide actionable agronomist advice.

| Class | Description |
|---|---|
| 🟡 **Early Blight** | Caused by *Alternaria solani*, shows dark lesions |
| 🔴 **Late Blight** | Caused by *Phytophthora infestans*, highly destructive |
| 🟢 **Healthy** | No disease detected |

---

## 🏗️ Cloud-Native Architecture

The platform is designed as a microservice architecture, orchestrated by Kubernetes, and fully integrated with AWS serverless and AI services.

```text
┌─────────────────────────────────────────────────────────────────────┐
│                             AWS Cloud                               │
│                                                                     │
│                      ┌───────────────────────┐                      │
│                      │ Amazon EC2 (K3s Node) │                      │
│                      │                       │                      │
│  ┌──────────┐        │  ┌─────────────────┐  │      ┌────────────┐  │
│  │ Cognito  │◀───────┼──│ React Frontend  │  │      │  Bedrock   │  │
│  │  (Auth)  │        │  └─────────────────┘  │      │(AI Advice) │  │
│  └──────────┘        │           │           │      └────────────┘  │
│                      │           ▼           │            ▲         │
│                      │  ┌─────────────────┐  │            │         │
│                      │  │ FastAPI Backend │──┼────────────┘         │
│                      │  │  (TensorFlow)   │  │                      │
│                      │  └────────┬────────┘  │                      │
│                      └───────────┼───────────┘                      │
│                                  │                                  │
│             ┌────────────────────┴────────────────────┐             │
│             ▼                    ▼                    ▼             │
│        ┌────────┐           ┌──────────┐         ┌─────────┐        │
│        │   S3   │           │ DynamoDB │         │   SNS   │        │
│        │(Images)│           │(Records) │         │(Alerts) │        │
│        └────────┘           └──────────┘         └─────────┘        │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Tech Stack & Infrastructure

| Layer | Technology Used |
|---|---|
| **ML Inference** | TensorFlow / Keras (`.h5` CNN Model) |
| **Backend API** | Python, FastAPI, Uvicorn |
| **Generative AI** | AWS Bedrock (Amazon Titan Text Express) |
| **Data & Storage** | AWS S3 (Images), Amazon DynamoDB (NoSQL Records) |
| **Authentication** | AWS Cognito (User Pools, SRP Auth) |
| **Frontend** | React.js, Vanilla CSS, Glassmorphism UI |
| **Containerization**| Docker, Multi-stage builds |
| **Orchestration** | Kubernetes (K3s, Deployments, Services, HPA, Ingress) |
| **Infrastructure** | Terraform (IaC automation) |

---

## 🌐 Deployment (Kubernetes on AWS EC2)

The application is deployed to a Kubernetes (K3s) cluster running on Amazon EC2. The entire infrastructure is codified using **Terraform** for automated provisioning and teardown. 

### Infrastructure as Code (Terraform)
1. Ensure AWS CLI is configured with appropriate permissions.
2. Navigate to `infrastructure/terraform/`.
3. Run the automated deployment:
```bash
terraform init
terraform apply -auto-approve
```
*This automatically provisions the EC2 instance, bootstraps K3s via cloud-init, configures Security Groups, and sets up all required AWS services (S3, DynamoDB, Cognito, SNS).*

### Kubernetes Orchestration
Once the EC2 cluster is running, the deployment script handles container image builds and applies the Kubernetes manifests:
```bash
./deploy_to_k3s.sh
```
*The K8s setup includes:*
- **Deployments:** Replicated pods for high availability.
- **Horizontal Pod Autoscaler (HPA):** Auto-scales backend from 2 to 10 pods based on CPU load.
- **Services & Ingress:** NodePort networking with Nginx Ingress routing.
- **Probes:** Liveness and Readiness probes for zero-downtime self-healing.

---

## 💻 Local Development Environment

For development, testing, and debugging, the entire platform can be spun up locally using Docker Compose, which mirrors the production container environment.

### Prerequisites
- Docker Desktop
- AWS CLI configured locally (`~/.aws/credentials`)

### Start the Local Cluster
```bash
# Clone the repository
git clone https://github.com/yash-raka/agrismart-disease-detection.git
cd agrismart-disease-detection

# Spin up the containers
docker-compose up --build

# Access the platform:
# Frontend UI: http://localhost:3001
# Backend API: http://localhost:8000
# Swagger API Docs: http://localhost:8000/docs
```

---

## 📁 Project Structure

```text
agrismart-disease-detection/
├── backend/              # FastAPI inference server + AWS service integration
├── frontend/             # React application with Cognito auth flow
├── infrastructure/       
│   ├── terraform/        # IaC for AWS (EC2, S3, DynamoDB, Cognito, SNS)
│   └── kubernetes/       # K8s Manifests (Deployments, HPA, Services, ConfigMaps)
├── model/                # ML model weights
└── deploy_to_k3s.sh      # Automated K8s deployment script
```

---

*Built by [Yash](https://github.com/yash-raka)*
