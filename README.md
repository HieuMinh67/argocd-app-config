## Prerequisites
To build this application, you will need:
- Terraform
- Helm CLI
- A running Kubernetes cluster. You can use my sample [repository](https://github.com/HieuMinh67/pod7) to build an
infrastructure for this repository

## Installation
- Deploy ArgoCD by using Terraform
```
terraform init
terraform plan
terraform apply
```
- Create namespace and deploy applications to namespace `argocd`
- 