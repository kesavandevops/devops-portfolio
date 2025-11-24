# Flask CI/CD & Canary Deployment Demo

This repository contains a complete, hands-on **DevOps portfolio project** that demonstrates an end-to-end CI/CD pipeline for a Python Flask web application using **Jenkins**, **Docker**, and **Kubernetes (AWS EKS)**. It includes Blue-Green and Canary deployment strategies and a simple traffic validation script.

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

## Repo Structure

```text
01-ci-cd-pipeline/
├── Dockerfile                   # Flask app container image
├── Jenkinsfile                  # CI/CD pipeline
├── canary-test.sh               # Script to test traffic distribution
├── README.md                    # This top-level README (you are reading it)
├── app.py                       # Flask application entry point
├── requirements.txt             # Python dependencies
└── k8s-manifests/
    ├── deployment.yaml          # Blue deployment (version=blue)
    ├── deployment-green.yaml    # Green/Canary deployment (version=green)
    └── service-lb.yaml          # LoadBalancer service selecting app: flask
```

---

## Overview

This project shows how to:
- Build a Docker image for a Flask app.
- Use Jenkins to build, push to Docker Hub, and deploy to EKS.
- Deploy Blue and Green versions of the app on Kubernetes.
- Perform Canary rollouts by changing replica counts.
- Validate traffic distribution with a simple `canary-test.sh` script.

---

## Prerequisites

- AWS account with EKS & EC2 access.  
- Jenkins installed on an EC2 instance (or local Linux VM) with docker & kubectl configured.  
- A Docker Hub account.  
- `kubectl` and `aws` CLI installed and configured on the machine where you'll run commands (or on the Jenkins host).  
- GitHub repo containing this project (so Jenkins can checkout the Jenkinsfile).

---

## Step 1 — Build & Push Docker Image (local or CI)

From the `01-ci-cd-pipeline/` directory (or from pipeline):

```bash
docker build -t <dockerhub-username>/flask-cicd-app:latest .
docker push <dockerhub-username>/flask-cicd-app:latest
```

> Replace `<dockerhub-username>` with your Docker Hub username.

---

## Step 2 — Jenkins Pipeline (CI/CD)

Create a Jenkins Pipeline job (Pipeline script from SCM) that points to this repository and the `Jenkinsfile` path (example `01-ci-cd-pipeline/Jenkinsfile`).

A minimal Jenkinsfile (example) that works with the repo layout:

```groovy
pipeline {
  agent any

  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds') // set this in Jenkins
    AWS_CREDENTIALS = 'aws-jenkins-creds'                  // set this in Jenkins (AWS plugin)
    AWS_REGION = 'ap-south-1'
  }

  stages {
    stage('Checkout') {
      steps {
        // If pipeline is configured "from SCM", this is implicit.
        git branch: 'main', url: 'https://github.com/<your-username>/devops-portfolio.git'
      }
    }

    stage('Build Docker') {
      steps {
        dir('01-ci-cd-pipeline') {
          sh 'docker build -t <dockerhub-username>/flask-cicd-app:latest .'
        }
      }
    }

    stage('Push Docker') {
      steps {
        withDockerRegistry([credentialsId: 'dockerhub-creds', url: '']) {
          sh 'docker push <dockerhub-username>/flask-cicd-app:latest'
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        withAWS(region: "${AWS_REGION}", credentials: "${AWS_CREDENTIALS}") {
          sh '''
            aws eks --region ${AWS_REGION} update-kubeconfig --name devops-cluster
            kubectl apply -f 01-ci-cd-pipeline/k8s-manifests/
          '''
        }
      }
    }
  }
}
```

**Notes:**
- Configure Jenkins credentials: `dockerhub-creds` (Docker Hub) and `aws-jenkins-creds` (AWS).  
- Install Jenkins plugins: *AWS Credentials* and *Pipeline: AWS Steps* (if you use `withAWS`), and Docker Pipeline plugin.

---

## Step 3 — Apply Kubernetes Manifests (manual or CI)

Apply all manifests in the `k8s-manifests/` folder (Deployment blue, Deployment green, Service):

```bash
kubectl apply -f 01-ci-cd-pipeline/k8s-manifests/
```

This will create/update:
- `flask-deployment` (Blue) — labeled `app=flask, version=blue`
- `flask-deployment-green` (Green/Canary) — labeled `app=flask, version=green`
- `flask-service` (LoadBalancer) — selects `app=flask` so it routes to both versions.

---

## Step 4 — Verify deployment & service

```bash
kubectl get deployments
kubectl get pods -o wide
kubectl get svc
kubectl describe svc flask-service
```

Check that `flask-service` has an **EXTERNAL-IP** / **LoadBalancer Ingress** (DNS). Use that DNS for testing and the canary script.

---

## Step 5 — Smoke test the app

```bash
curl http://<LOADBALANCER_DNS>/
```

You should get responses containing either:

- `Hello from BLUE version of Flask App`  
or
- `Hello from GREEN version of Flask App`

(Your `app.py` uses `APP_COLOR` env variable to render this.)

---

## Step 6 — Canary workflow (example: 4 Blue / 1 Green)

### 6.1 Set initial counts (idempotent)

```bash
kubectl scale deployment/flask-deployment --replicas=4
kubectl scale deployment/flask-deployment-green --replicas=1

kubectl rollout status deployment/flask-deployment
kubectl rollout status deployment/flask-deployment-green
```

### 6.2 Validate endpoints & distribution

```bash
kubectl get endpoints flask-service -o wide
# Use canary-test.sh to measure distribution (see below)
```

### 6.3 Shift traffic gradually (example sequence)

Run each step, wait for rollouts to finish, then test distribution.

- Step A (initial) — 4 Blue / 1 Green
- Step B — 3 Blue / 2 Green
  ```bash
  kubectl scale deployment/flask-deployment --replicas=3
  kubectl scale deployment/flask-deployment-green --replicas=2
  kubectl rollout status deployment/flask-deployment
  kubectl rollout status deployment/flask-deployment-green
  ```
- Step C — 2 Blue / 3 Green
  ```bash
  kubectl scale deployment/flask-deployment --replicas=2
  kubectl scale deployment/flask-deployment-green --replicas=3
  ```
- Step D — 1 Blue / 4 Green
- Step E — 0 Blue / 5 Green (final cutover)

After each change, run the traffic test (next section) to confirm the distribution.

---

## Step 7 — Traffic validation script (`canary-test.sh`)

Place `canary-test.sh` at `01-ci-cd-pipeline/canary-test.sh`. Example content:

```bash
#!/bin/bash
# Usage: ./canary-test.sh <LOADBALANCER_DNS> [NUMBER_OF_REQUESTS]
LB="${1:?please provide LB DNS or NODE_IP:PORT}"
N="${2:-100}"

blue=0; green=0

for i in $(seq 1 $N); do
  r=$(curl -s "http://$LB/")
  if [[ "$r" == *"BLUE"* ]]; then
    blue=$((blue+1))
  elif [[ "$r" == *"GREEN"* ]]; then
    green=$((green+1))
  fi
done

total=$((blue + green))
if [ $total -eq 0 ]; then
  echo "No valid responses received. Check LB/NodePort connectivity and app output."
  exit 1
fi

blue_pct=$((blue * 100 / total))
green_pct=$((green * 100 / total))

echo "Results after $total requests:"
echo "BLUE  : $blue responses ($blue_pct%)"
echo "GREEN : $green responses ($green_pct%)"
```

Run:

```bash
chmod +x 01-ci-cd-pipeline/canary-test.sh
./01-ci-cd-pipeline/canary-test.sh <LOADBALANCER_DNS> 100
```

This shows the percentage split (e.g., with 4:1 you should see ~80% BLUE, ~20% GREEN).

---

## Step 8 — Rollback strategies

If the green release shows problems at any stage, rollback quickly:

- Scale green down and restore blue replicas:
  ```bash
  kubectl scale deployment/flask-deployment-green --replicas=0
  kubectl scale deployment/flask-deployment --replicas=4
  ```

- Or use rollout undo:
  ```bash
  kubectl rollout undo deployment/flask-deployment-green
  ```

---

## Step 9 — Cleanup (delete cluster & resources)

**Warning:** This will remove resources and stop billing for the cluster. Ensure you do not delete shared resources used by others.

If you used `eksctl` to create the cluster, delete the nodegroups first (optional) then the cluster:

```bash
eksctl get nodegroup --cluster devops-cluster --region ap-south-1
eksctl delete nodegroup --cluster devops-cluster --name <nodegroup-name> --region ap-south-1

# delete cluster
eksctl delete cluster --name devops-cluster --region ap-south-1
```

You can also delete the cluster via `aws eks delete-cluster --name devops-cluster --region ap-south-1` and then remove EC2 instances and load balancers from the EC2 console if any remain.

---

## Notes & Best Practices

- Use **readinessProbe** in each deployment so only healthy pods receive traffic.  
- Use **livenessProbe** to restart crashed pods.  
- Keep Jenkins credentials secure and use IAM roles where possible (attach IAM role to EC2 / use IRSA in production).  
- For production workflows, consider introducing automated smoke tests between Canary steps to automatically progress or rollback.
