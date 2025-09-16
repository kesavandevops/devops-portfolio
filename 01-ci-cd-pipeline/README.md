# Flask CI/CD & Canary Deployment Demo

This project demonstrates a **full DevOps pipeline** for a Python Flask web application, including **CI/CD with Jenkins**, **Docker containerization**, and **Blue-Green / Canary deployment strategies** on **AWS EKS**.  

It showcases real-world DevOps practices suitable for production environments.

---

## Tech Stack

- **AWS EKS & EC2** – Kubernetes cluster and Jenkins host  
- **Jenkins** – CI/CD automation  
- **Docker** – Containerization of Flask app  
- **Python Flask** – Sample web application  
- **GitHub** – Source code repository  
- **Docker Hub** – Container image registry  
- **Kubernetes** – Blue-Green & Canary deployment orchestration  

---

## Project Overview

1. **CI/CD Pipeline**
   - Source code stored in **GitHub** repository.
   - Jenkins pipeline builds Docker image, pushes to Docker Hub, and deploys to AWS EKS.
   - Pipeline uses `kubectl apply -f k8s-manifests/` to deploy all Kubernetes manifests.

2. **Blue-Green Deployment**
   - `deployment.yaml` → Blue version of the app  
   - `deployment-green.yaml` → Green version of the app  
   - `service-lb.yaml` → LoadBalancer service directing traffic to pods.
   - Allows **instant traffic switch** with zero downtime.

3. **Canary Deployment**
   - Both Blue & Green pods run simultaneously.
   - Traffic is gradually shifted by adjusting **replica counts** in deployments.
   - `canary-test.sh` script measures traffic distribution between Blue & Green pods to validate rollout.

---

## Repo Structure

01-ci-cd-pipeline/
├── Dockerfile # Flask app container image
├── Jenkinsfile # CI/CD pipeline
├── canary-test.sh # Script to test traffic distribution
├── README.md # This top-level README
└── k8s-manifests/
├── deployment.yaml # Blue deployment
├── deployment-green.yaml # Green/Canary deployment
└── service-lb.yaml # LoadBalancer service
