# 06 – Enterprise DevOps Workflow (End-to-End)

**Code → GitHub → Jenkins → Trivy → Docker → ECR → EKS → Ansible → Prometheus/Grafana → Splunk → Slack → HPA**

This project showcases an **end-to-end Enterprise-grade DevOps workflow** built around a containerized Flask application deployed to **Amazon EKS**, with:

- CI/CD using **Jenkins**
- Image scanning using **Trivy**
- Image storage in **AWS ECR**
- Deployment & infra automation via **Ansible**
- Monitoring with **Prometheus + Grafana**
- Centralized logging in **Splunk**
- Notifications to **Slack**
- Auto-scaling with **Kubernetes HPA**

It’s designed as a portfolio-ready project to prove real-world DevOps skills.

---

## 📌 High-Level Architecture

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant GH as GitHub
    participant J as Jenkins
    participant T as Trivy
    participant ECR as AWS ECR
    participant EKS as EKS Cluster
    participant A as Ansible
    participant P as Prometheus/Grafana
    participant S as Splunk
    participant SL as Slack
    participant User as End User

    Dev->>GH: Push code (Flask app, Ansible, k8s manifests)
    GH->>J: Webhook / manual trigger
    J->>J: Build Docker image
    J->>T: Scan image (HIGH/CRITICAL)
    T-->>J: Pass/Fail result
    J->>ECR: Push image on success
    J->>EKS: aws eks update-kubeconfig
    J->>A: Run Ansible deploy.yaml (k8s deployment/service/hpa)
    J->>A: Run configure-monitoring.yaml (Prometheus+Grafana)
    J->>A: Run configure-logging.yaml (Splunk + UF)
    A->>EKS: Apply/Update K8s resources
    User->>EKS: HTTP requests to Flask service
    EKS->>P: Metrics scraped (`/metrics`, node, pods)
    EKS->>S: Logs forwarded via Splunk UF
    J-->>SL: Success/Failure notifications
    P-->>SL: Alerts (optional)
````

---

## 🧱 Tech Stack

* **App:** Python Flask + Prometheus client
* **Containerization:** Docker
* **Registry:** AWS ECR
* **CI/CD:** Jenkins (Pipeline + Trivy image scan)
* **Orchestration:** Kubernetes on AWS EKS
* **Automation:** Ansible (`kubernetes.core` collection)
* **Monitoring:** Prometheus + Grafana
* **Logging:** Splunk Enterprise + Fluent Bit (DaemonSet)
* **Alerting:** Slack (Jenkins notifications; Prometheus optional)
* **Scaling:** Kubernetes HPA (Horizontal Pod Autoscaler)

---

## 📂 Repository Structure

```text
06-enterprise-project/
├── app/
│   ├── app.py                         # Flask app with /, /api/health and /metrics
│   ├── requirements.txt               # Python dependencies
│   └── Dockerfile                     # Builds the Flask container
│
├── ansible/
│   ├── playbooks/
│   │   ├── deploy.yaml                # Deploys app/service/HPA to EKS
│   │   ├── configure-logging.yaml     # Splunk Enterprise + Fluent Bit DaemonSet
│   │   └── configure-monitoring.yaml  # Prometheus + Grafana stack
│   └── inventory/
│       └── hosts.ini                  # Local inventory (usually localhost)
│
├── jenkins/
│   └── Jenkinsfile                    # Full CI/CD pipeline (Trivy + ECR + Ansible)
│
├── k8s/
│   ├── deployment.yaml.j2             # Jinja2 template for Deployment (image injected)
│   ├── service.yaml                   # Service (LoadBalancer or ClusterIP)
│   └── hpa.yaml                       # HPA definition
│
└── README.md
```

---

## ✅ Prerequisites

### 1. AWS / Kubernetes

* AWS account with permissions to:

  * Manage **ECR** (create repositories, push/pull images)
  * Manage **EKS** (describe, update kubeconfig)
  * Read/write to EKS cluster resources (pods, services, deployments, etc.)

* An existing **EKS cluster**, e.g.:

  * Name: `enterprise-eks-cluster`
  * Region: `ap-south-1`
  * Nodes with enough capacity to run:

    * Flask pods
    * Prometheus + Grafana
    * Splunk + Fluent Bit Forwarder

* `aws` CLI configured on:

  * Your **local machine** (if running Ansible manually)
  * The **Jenkins agent** (for `aws eks update-kubeconfig` and ECR login)

* `kubectl` on:

  * Your machine (for manual checks)
  * Jenkins agent (for validation step like `kubectl get ns`)

* `metrics-server` installed on EKS (for HPA to function).

---

### 2. ECR Repository

Create a repository for your app images:

```bash
AWS_REGION=ap-south-1
ECR_REPO=enterprise-devops-app

aws ecr create-repository \
  --repository-name ${ECR_REPO} \
  --region ${AWS_REGION}
```

---

### 3. Jenkins Server

On the Jenkins agent (or master if building there), you must have:

* Docker
* AWS CLI
* kubectl
* ansible
* trivy
* Slack plugin (or `slackSend` configured)
* AWS Credentials installed in Jenkins Credentials:

  * `aws_account_id` (type: secret text) → your AWS account ID
  * `aws_creds` (AWS access key credentials / or role mapping)

Plugins typically used:

* **Pipeline** (Declarative)
* **AWS Steps** (for `withAWS`)
* **Slack Notification**
* **Credentials Binding**

---

### 4. Python / Ansible Dependencies

On the Jenkins agent and/or local where you run Ansible:

```bash
pip install ansible
ansible-galaxy collection install kubernetes.core
```

Ensure `K8S_AUTH_KUBECONFIG` support via environment variable is available for `kubernetes.core.k8s`.

---

### 5. Splunk & Monitoring Defaults

The playbooks assume:

* Splunk:

  * Image: `splunk/splunk:9.2`
  * Admin password: `DevOps@123` (you should override in vars)
  * Splunk exposed via Kubernetes **Service** in `logging` namespace:

    * Web UI: Port `8000`
    * HEC: Port `8088`

* Prometheus:

  * Single deployment in `monitoring` namespace
  * Configured to scrape `flask-service.enterprise.svc.cluster.local:5000` `/metrics`

* Grafana:

  * Single deployment in `monitoring` namespace
  * Exposed via LoadBalancer or NodePort

You can adjust all of these in `configure-monitoring.yaml` and `configure-logging.yaml`.

---

## 🔁 End-to-End Pipeline Flow (What Jenkinsfile Does)

Your `jenkins/Jenkinsfile` roughly performs:

1. **Checkout Code**

   * Pulls repo from GitHub (branch: `main`).

2. **Build Docker Image**

   * Builds Docker image from `app/Dockerfile`.
   * Tags it with `DOCKER_IMAGE = <ACCOUNT>.dkr.ecr.<region>.amazonaws.com/enterprise-devops-app:<BUILD_NUMBER>`.

3. **Scan Docker Image with Trivy**

   * Runs `trivy image --severity HIGH,CRITICAL --exit-code 1 $DOCKER_IMAGE`
   * If vulnerabilities of severity HIGH or CRITICAL are found, build **fails**.

4. **Login to AWS ECR**

   * Uses AWS credentials (`withAWS`) and `aws ecr get-login-password` to log Docker into ECR registry.

5. **Push Docker Image**

   * Pushes the tagged image to ECR.

6. **Set Kubernetes Context**

   * Runs `aws eks update-kubeconfig --name enterprise-eks-cluster --region ap-south-1 --kubeconfig $WORKSPACE/.kube/config`
   * Validates with `kubectl get ns`.

7. **Deploy Application (Ansible)**

   * Navigates to `ansible/`
   * Runs `ansible-playbook playbooks/deploy.yaml`
   * Playbook uses `k8s/` manifests (`deployment.yaml.j2`, `service.yaml`, `hpa.yaml`) to:

     * Deploy/update the Flask app Deployment
     * Expose Service (LoadBalancer or ClusterIP)
     * Apply HPA configuration

8. **Configure Logging (Ansible)**

   * Runs `ansible-playbook playbooks/configure-logging.yaml`
   * Deploys:

     * `logging` namespace
     * Splunk Enterprise Deployment + Service
     * Splunk Universal Forwarder DaemonSet
     * ConfigMaps/Secrets for Splunk and UF

9. **Configure Monitoring (Ansible)**

   * Runs `ansible-playbook playbooks/configure-monitoring.yaml`
   * Deploys:

     * `monitoring` namespace
     * Prometheus Deployment + Service + ConfigMap
     * Grafana Deployment + Service

10. **Post Actions (Slack)**

    * On success: sends ✅ message with image tag to Slack channel (e.g., `#devops-alerts`).
    * On failure: sends ❌ message with a failure note.

---

## 🧪 How to Run & Test

### 1. Trigger Jenkins Pipeline

* Option A: Configure a GitHub webhook to automatically trigger on `push` to `main`.
* Option B: Manually build the Jenkins job from the Jenkins UI.

Watch console output for stages:

* Build Docker Image
* Scan Docker Image with Trivy
* Login to AWS ECR
* Push Docker Image
* Set Kubernetes Context
* Deploy Application (Ansible)
* Configure Logging
* Configure Monitoring
* Slack Notifications

---

### 2. Verify Deployment on EKS

```bash
# Check namespace
kubectl get ns

# Check app resources
kubectl get deploy,svc,hpa -n enterprise
kubectl get pods -n enterprise -o wide

# Port-forward (if Service is not public)
kubectl port-forward svc/flask-service 8080:80 -n enterprise

# Test app
curl http://localhost:8080/
curl http://localhost:8080/api/health
curl http://localhost:8080/metrics
```

You should see:

* JSON response from `/` and `/api/health`
* Prometheus-formatted metrics from `/metrics`

---

### 3. Verify Monitoring (Prometheus + Grafana)

```bash
kubectl get pods -n monitoring
kubectl get svc -n monitoring
```

* Port-forward Prometheus:

  ```bash
  kubectl port-forward svc/prometheus 9090:9090 -n monitoring
  ```

  Open: `http://localhost:9090/targets` and confirm `flask-service` target is **UP**.

* Port-forward Grafana:

  ```bash
  kubectl port-forward svc/grafana 3000:3000 -n monitoring
  ```

  Open: `http://localhost:3000/`

  * Add Prometheus datasource at `http://prometheus:9090`
  * Import dashboards for app & system metrics (if you have JSONs from Project 03)

---

### 4. Verify Logging (Splunk)

```bash
kubectl get pods -n logging
kubectl get svc -n logging
```

* Port-forward Splunk web:

  ```bash
  kubectl port-forward svc/splunk-enterprise 8000:8000 -n logging
  ```

  Open: `http://localhost:8000`
  Login:

  * Username: `admin`
  * Password: (whatever you set in `configure-logging.yaml`, e.g., `DevOps@123`)

* Search for logs:

  ```spl
  index=main sourcetype="kube:container"
  ```

You should see container logs from the `enterprise` namespace (Flask pods, etc.).

---

### 5. Verify Autoscaling (HPA)

1. Check HPA status:

   ```bash
   kubectl get hpa -n enterprise
   kubectl describe hpa flask-hpa -n enterprise
   ```

2. Generate load:

   * If using port-forward to `localhost:8080`:

     ```bash
     hey -z 2m -c 50 http://localhost:8080/
     # or
     while true; do curl -s http://localhost:8080/ > /dev/null; done
     ```
   * Or target LoadBalancer external IP if available.

3. Watch scaling:

   ```bash
   kubectl get pods -n enterprise --watch
   kubectl get hpa -n enterprise --watch
   ```

You should see the number of `flask-app` pods increase when CPU usage rises above target, then scale down when idle.

---

## 🧹 Cleanup

To remove resources created by this project:

```bash
# App namespace
kubectl delete ns enterprise

# Monitoring
kubectl delete ns monitoring

# Logging
kubectl delete ns logging

# (Optional) delete ECR images
aws ecr batch-delete-image \
  --repository-name enterprise-devops-app \
  --image-ids imageTag=<tag> \
  --region ap-south-1
```

(If your cluster / infra was provisioned by Terraform, destroy with your Terraform workflows.)

---

## 🎯 What This Project Demonstrates to Interviewers

* Real-world CI/CD using **Jenkins Pipelines**
* Security-first approach with **Trivy** image scanning
* Cloud-native deployment to **EKS** with **Ansible** automation
* **Observability**: metrics (Prometheus/Grafana) + logs (Splunk)
* **Alerting & ChatOps** with Slack
* **Scalability & Resilience** with Kubernetes HPA

This project is a strong “capstone” in your portfolio that shows you can design and run an **end-to-end production-grade DevOps workflow**.

```

---

If you want, next I can:

- Add a **short demo script** (`demo-runbook.md` or `.sh`) that you can literally follow live in interviews:  
  *“Step 1: trigger Jenkins, Step 2: show EKS pods, Step 3: show Grafana, Step 4: show Splunk logs, Step 5: show HPA scaling.”*
```
