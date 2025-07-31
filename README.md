# Todo List Application - Individual DevOps Project

This repository demonstrates my individual implementation of a complete DevOps pipeline for deploying a todo list application. The project showcases practical DevOps skills through containerization, infrastructure automation, and continuous deployment.

##  Project Overview

This individual project is divided into three main parts, each building upon the previous to create a complete deployment pipeline:


##  Project Structure

```
todo-list-app/
├── Todo-List-nodejs/              # Original application
|
├── deployment/                    # Deployment configuration
│   ├── docker-compose.yml         # Multi-service orchestration
│   ├── Dockerfile                 # Application container
│   └── scripts/
│       └── auto-update-image.sh   # Advanced auto-update script
├── infrastructure/                 # Infrastructure as Code
│   ├── ansible/                   # Configuration management
│   │   ├── inventory.yml          # Server inventory
│   │   ├── playbook.yml           # Server setup automation
│   │   ├── roles/
│   │   │   └── todo-app-setup/   # Application setup role
│   │   └── vars/                  # Ansible variables
│   └── terraform/                 # Infrastructure as Code
│       ├── main.tf                # Main infrastructure definition
│       ├── variables.tf           # Input variables
│       ├── outputs.tf             # Output values
│       ├── provider.tf            # AWS provider configuration
│       └── modules/               # Reusable infrastructure modules
├── k8s-infrastructure/            # Kubernetes infrastructure
│   ├── terraform/                 # K8s cluster infrastructure
│   │   ├── main.tf                # Main K8s infrastructure
│   │   ├── variables.tf           # K8s variables
│   │   ├── outputs.tf             # K8s outputs
│   │   └── modules/               # K8s infrastructure modules
│   ├── ansible/                   # K8s cluster configuration
│   │   ├── inventory/             # K8s hosts inventory
│   │   ├── roles/                 # K8s configuration roles
│   │   └── site.yml               # K8s setup playbook
│   └── README.md                  # K8s infrastructure documentation
├── helm/                          # Helm charts and ArgoCD
│   ├── todo-app-manifests/        # Todo application Helm chart
│   │   ├── Chart.yaml             # Chart metadata
│   │   ├── values.yaml            # Chart values
│   │   ├── templates/             # K8s manifests
│   │   └── .argocd-source-todo-app.yaml # ArgoCD source config
│   └── argocd/                    # ArgoCD configuration
│       ├── argocd-application.yaml # ArgoCD application
│       ├── argocd-configmap.yaml  # ArgoCD config
│       ├── git-credentials-secret.yaml # Git credentials
│       └── install.sh             # ArgoCD installation script
└── .github/                       # CI/CD pipeline
    └── workflows/
        └── docker-build.yml       # GitHub Actions workflow
```


### 🎯 Part 1: Application Containerization & CI
**Goal**: Take a Node.js application dockerize it and create a complete CI pipeline

### 🎯 Part 2: Infrastructure Automation
**Goal**: Automate server provisioning using terraform, setup and configuration using Ansible

### 🎯 Part 3: Production Deployment & Auto-Updates 
**Goal**: Deploy the application with health monitoring and automatic updates

### 🎯 Part 4: Bonus - Kubernetes & ArgoCD (50 points)
**Goal**: Replace Docker Compose with Kubernetes and implement ArgoCD for continuous deployment and Argo Image updater for automatic image updates.

---

##  Part 1: Application Containerization & CI

### Implementation Details

#### 1. Cloned the Original Application
```bash
git clone https://github.com/Ankit6098/Todo-List-nodejs
cd Todo-List-nodejs
```

#### 2. Set Up MongoDB Database
- Created a MongoDB database connection
- Updated the `.env` file with the database connection string
- Ensured the database is accessible from the application


#### 3. Dockerized the Application
Created an optmized `Dockerfile` in the `Todo-List-nodejs/` directory:

```dockerfile
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .

EXPOSE 4000
ENV PORT=4000

CMD ["index.js"]
```

#### 4. Created GitHub Actions CI Pipeline
Set up automated builds and pushes to Docker Hub registry:

- **Registry**: Using Docker Hub (omniasaad/todo-app)
- **Automated builds**: On every push to master branch
- **Image tagging**: Using timestamp format (YYYYMMDD-HHMM)
- **Security**: Private registry access with secrets

### Why This Matters
- **Containerization**: Makes the application portable and consistent across environments
- **CI**: Automates testing and building the App
- **Private Registry**: Ensures security and control over application images

---

##  Part 2: Infrastructure Automation with Ansible and terraform

### Implementation Details

#### 1. Created Linux VM
- **Platform**: AWS EC2 instance
- **OS**: Ubuntu 22.04 LTS
- **Instance Type**: t3.medium
- **Security**: SSH key-based access

###  Infrastructure as Code with Terraform

#### Complete AWS Infrastructure
Created comprehensive Terraform configuration in `infrastructure/terraform/`:

```hcl
# infrastructure/terraform/main.tf
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  environment          = var.environment
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
}

module "ec2" {
  source = "./modules/ec2"
  
  environment        = var.environment
  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = module.vpc.vpc_cidr_block
  public_subnet_ids = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  
  instance_type     = var.instance_type
  key_name          = var.key_name
  ami_id            = var.ami_id
  
  app_port          = var.app_port
  ssh_port          = var.ssh_port
  mongo_port        = var.mongo_port
}
```

#### VPC Module Features (`modules/vpc/`)
- **Custom VPC**: Isolated network environment (10.0.0.0/16)
- **Public/Private Subnets**: Security segmentation across multiple AZs
- **Internet Gateway**: External connectivity for public subnets
- **Route Tables**: Traffic routing configuration

#### EC2 Module Features (`modules/ec2/`)
- **Security Groups**: Firewall rules for application access
- **Health Checks**: Instance monitoring

#### Configuration Variables (`variables.tf`)
```hcl
# AWS Configuration
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# EC2 Configuration
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

# Application Configuration
variable "app_port" {
  description = "Application port"
  type        = number
  default     = 4000
}
```

#### 2. Set Up Ansible on Local Machine
```bash
# Installed Ansible
sudo apt update
sudo apt install ansible

# Verified installation
ansible --version
```

#### 3. Configured Ansible Inventory
Created `infrastructure/ansible/inventory.yml`:

```yaml
all:
  children:
    servers:
      hosts:
        todo-app-server:
          ansible_host: VM_IP_ADDRESS
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/todo-app.pem
```

#### 4. Created Comprehensive Ansible Playbook
Built a modular playbook structure in `infrastructure/ansible/playbook.yml`:

```yaml
---
- name: Setup VM for Todo App
  hosts: all
  become: yes
  vars_files:
    - vars/docker-credentials.yml  
  roles:
    - todo-app-setup
```

#### 5. Developed Advanced Ansible Roles
Created a comprehensive role structure in `infrastructure/ansible/roles/todo-app-setup/`:

**Main Tasks (`tasks/main.yml`):**
```yaml
---
- name: Include system setup tasks
  include_tasks: system-setup.yml

- name: Include Docker installation tasks
  include_tasks: docker-setup.yml

- name: Include application deployment tasks
  include_tasks: app-deployment.yml

```

**Specialized Task Files:**
- `system-setup.yml`: OS hardening, user management, firewall configuration
- `docker-setup.yml`: Docker installation, Docker Compose, registry configuration
- `app-deployment.yml`: Application deployment, environment configuration

#### 6. Encrypt Docker credentials
use `ansible-vualt` to encrypt docker credentials in `ansible/vars/docker-credentials.yml`


#### 7. Ran Ansible Playbook
```bash
# Test connectivity
ansible all -m ping

# Run the playbook
ansible-playbook -i inventory.yml playbook.yml --ask-vualt-pass
```

### Why This Matters
- **Infrastructure as Code**: Server configuration is version-controlled and repeatable
- **Automation**: No manual server setup required
- **Consistency**: Every server gets the same configuration
- **Scalability**: Easy to apply the same setup to multiple servers

---

##  Part 3: Production Deployment & Auto-Updates

### Implementation Details

#### 1. Created Production-Grade Docker Compose
Built `deployment/docker-compose.yml` with comprehensive configuration:

```yaml
services:
  app:
    image: omniasaad/todo-app:20250727-1352
    ports:
      - "4000:4000"
    environment:
      - PORT=${PORT}
      - mongoDbUrl=${mongoDbUrl}
    depends_on:
      mongo:
        condition: service_healthy
    networks:
      - app-network
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M

  mongo:
    image: mongo:6.0
    ports:
      - "27017:27017"
    environment:
      - MONGO_INITDB_DATABASE=${MONGO_INITDB_DATABASE}
      - MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME}
      - MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
    volumes:
      - mongo_data:/data/db
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M

volumes:
  mongo_data:

networks:
  app-network:
    driver: bridge
```

#### 2. Implemented Advanced Auto-Update System
Created `deployment/scripts/auto-update-image.sh` with sophisticated features:

```bash
#!/bin/bash

IMAGE_NAME="omniasaad/todo-app"

# Get latest remote tag (sorted by time)
LATEST_TAG=$(curl -s "https://registry.hub.docker.com/v2/repositories/${IMAGE_NAME}/tags?page_size=100" |
  grep -oE '"name":"[0-9]{8}-[0-9]{4}"' |
  cut -d':' -f2 | tr -d '"' | sort -r | head -n1)

echo "Latest tag: $LATEST_TAG"

if [ -z "$LATEST_TAG" ]; then
  echo " Failed to fetch latest tag."
  exit 1
fi

# Get current tag from docker-compose.yml
CURRENT_TAG=$(grep "$IMAGE_NAME" docker-compose.yml | cut -d: -f3)

if [ -z "$CURRENT_TAG" ]; then
  echo " Could not detect current tag in docker-compose.yml"
  exit 1
fi

echo " Current tag in compose: $CURRENT_TAG"

# Compare tags
if [ "$CURRENT_TAG" != "$LATEST_TAG" ]; then
  echo " New tag detected. Updating docker-compose.yml..."

  # Backup the original docker-compose.yml
  cp docker-compose.yml docker-compose.yml.bak

  # Replace the tag in docker-compose.yml
  sed -i "s/${CURRENT_TAG}/${LATEST_TAG}/" docker-compose.yml

  # Pull new image and restart
  docker compose pull app
  docker compose up -d app

  echo " Waiting 60s for app to stabilize..."
  sleep 60
   APP_ID=$(docker compose ps -q app)
   RESTARTS=$(docker inspect --format='{{.RestartCount}}' "$APP_ID")
   STATUS=$(docker inspect --format='{{.State.Status}}' "$APP_ID")

   echo " App restart count: $RESTARTS"
   echo " App status: $STATUS"

    # If app restarted too much or exited, roll back
    if [[ "$RESTARTS" -ge 3 || "$STATUS" == "exited" ]]; then
    echo " App is unhealthy (restarts: $RESTARTS, status: $STATUS). Rolling back to $CURRENT_TAG..."

    # Restore previous docker-compose.yml
    mv docker-compose.yml.bak docker-compose.yml

    # Pull and redeploy previous tag
    docker compose pull app
    docker compose up -d app

    echo " Rolled back to $CURRENT_TAG"
  else
    echo " App is healthy with $LATEST_TAG"
    rm -f docker-compose.yml.bak
  fi
else
  echo " Already using the latest tag: $CURRENT_TAG"
fi
```


#### Intelligent Update Script
The auto-update system includes sophisticated features:

- **Remote Registry Monitoring**: Checks Docker Hub for new images
- **Safe Deployment**: Health checks before and after updates
- **Automatic Rollback**: Reverts on deployment failures
- **Logging**: Comprehensive update logging


### Why This Matters
- **Health Checks**: Ensures the application is actually working, not just running
- **Auto-Updates**: Keeps the application current with minimal downtime
- **Rollback Capability**: Can quickly revert if an update causes issues
- **Production Ready**: Handles real-world deployment scenarios

---

##  Part 4: Bonus - Kubernetes & ArgoCD Implementation

### Implementation Details

I implemented a complete Kubernetes cluster over AWS EC2 VMs and ArgoCD solution that demonstrates enterprise-level container orchestration and GitOps practices.

#### 1. Kubernetes Infrastructure Setup
Created a complete Kubernetes cluster infrastructure in `k8s-infrastructure/`:

**Terraform Configuration (`k8s-infrastructure/terraform/`):**
```hcl
# Main infrastructure configuration
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  environment          = var.environment
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
}

module "kubernetes" {
  source = "./modules/kubernetes"
  
  environment        = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  
  control_plane_count = var.control_plane_count
  worker_node_count   = var.worker_node_count
  instance_type      = var.instance_type
}
```

**Cluster Architecture:**
- **1 Control Plane Node**: t3.medium instance for cluster management
- **2 Worker Nodes**: t3.medium instances for application workloads
- **VPC with Public/Private Subnets**: Network segmentation for security
- **Security Groups**: Configured for Kubernetes communication

#### Security Group Inbound Rules for Kubernetes Cluster

**Control Plane Security Group (`control_plane`)**

| **Rule**               | **Port(s)**     | **Protocol** | **Source**         | **Purpose**                                                                 |
|------------------------|-----------------|--------------|--------------------|------------------------------------------------------------------------------|
| Internal VPC traffic   | 0-65535         | All (-1)     | VPC CIDR (`var.vpc_cidr`) | Allow all communication within the VPC (control ↔ worker).                  |
| SSH                    | 22              | TCP          | `0.0.0.0/0`         | Allow SSH access to control plane for management.                           |
| Kubernetes API Server  | 6443            | TCP          | `0.0.0.0/0`         | Access Kubernetes API server via `kubectl`, etc.                            |
| etcd Client API        | 2379-2380       | TCP          | VPC CIDR            | Internal communication with etcd (cluster database).                        |
| Kubelet API            | 10250           | TCP          | VPC CIDR            | Control plane to worker nodes (health checks, etc.).                        |
| NodePort Services      | 30000-32767     | TCP          | `0.0.0.0/0`         | Expose NodePort services to external traffic.                               |

---

**Worker Node Security Group (`worker_node`)**

| **Rule**               | **Port(s)**     | **Protocol** | **Source**         | **Purpose**                                                                 |
|------------------------|-----------------|--------------|--------------------|------------------------------------------------------------------------------|
| SSH                    | 22              | TCP          | `0.0.0.0/0`         | Allow SSH access to worker nodes.                                           |
| Internal VPC traffic   | 0-65535         | All (-1)     | VPC CIDR            | Allow internal communication with control plane and other workers.          |
| Kubernetes API Server  | 6443            | TCP          | `0.0.0.0/0`         | Allow worker to access API server.                                          |
| Kubelet API            | 10250           | TCP          | VPC CIDR            | Control plane access to worker's kubelet.                                   |
| NodePort Services      | 30000-32767     | TCP          | `0.0.0.0/0`         | External access to applications via NodePort.                               |

---




#### 2. Helm Chart Development
Created a comprehensive Helm chart in `helm/todo-app/`:

**Chart Configuration (`Chart.yaml`):**
```yaml
apiVersion: v2
name: todo-app
description: A simple Todo List application
type: application
version: 0.1.0
appVersion: "1.0.0"
```

**Values Configuration (`values.yaml`):**
```yaml
# Simple Todo App Configuration
replicaCount: 2

app:  
  image: omniasaad/todo-app:20250727-2309
  imagePullPolicy: Always
  pullPolicy: IfNotPresent

service:
  type: LoadBalancer
  port: 80
  targetPort: 4000

resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi

# MongoDB Configuration
mongodb:
  enabled: true
  image:
    repository: mongo
    tag: "6.0"
  auth:
    rootUsername: admin
    rootPassword: pass
    database: todo-list
  persistence:
    enabled: true
    size: 1Gi
  service:
    type: ClusterIP
    port: 27017

# Application Configuration
app_config:
  port: 4000
  mongoDbUrl: "mongodb://admin:pass@todo-app-mongodb:27017/todo-list?authSource=admin"
```

**Kubernetes Manifests (`templates/`):**
- `deployment.yaml`: Application deployment with resource limits
- `service.yaml`: NodePort service for external access
- `mongodb-statefulset.yaml`: Persistent MongoDB deployment
- `mongodb-service.yaml`: Internal MongoDB service
- `namespace.yaml`: Application namespace
- `pv.yaml`: Persistent volume for MongoDB

#### 3. ArgoCD Implementation
Implemented GitOps continuous deployment with ArgoCD:

**ArgoCD Application (`helm/argocd/argocd-application.yaml`):**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: todo-app
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd-image-updater.argoproj.io/image-list: todo-app=omniasaad/todo-app
    argocd-image-updater.argoproj.io/todo-app.helm.image-spec: app.image
    argocd-image-updater.argoproj.io/write-back-method: git
    argocd-image-updater.argoproj.io/git-branch: master
    argocd-image-updater.argoproj.io/update-strategy: latest
    argocd-image-updater.argoproj.io/force-update: "false"
spec:
  project: default
  source:
    repoURL: https://github.com/OmniaSaad0/todo-app-manifests
    targetRevision: master
    path: .
    helm:
      valueFiles:
        - values.yaml

  destination:
    server: https://kubernetes.default.svc
    namespace: todo-app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
      - PruneLast=true
  revisionHistoryLimit: 10
```

**ArgoCD Installation (`helm/argocd/install.sh`):**
```bash
#!/bin/bash

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Apply ArgoCD application
kubectl apply -f argocd-application.yaml
```

#### 4. Advanced Features Implemented

**Kubernetes Features:**
- **High Availability**: Multi-node cluster with load balancing
- **Resource Management**: CPU and memory limits for applications
- **Persistent Storage**: MongoDB data persistence across pod restarts
- **Service Discovery**: Internal service communication

**ArgoCD Features:**
- **GitOps**: Declarative configuration management
- **Automated Sync**: Automatic deployment on Git changes
- **Image Updates**: Automatic image updates with ArgoCD Image Updater
- **Self-Healing**: Automatic recovery from manual changes
- **Rollback Capability**: Easy rollback to previous versions

---

This individual project demonstrates comprehensive DevOps skills, from basic containerization to enterprise-level infrastructure automation and cloud-native deployment practices. Each part builds upon the previous, creating a complete understanding of the deployment pipeline from development to production, with additional enterprise-grade features that showcase advanced DevOps capabilities including Kubernetes orchestration and GitOps continuous deployment. 