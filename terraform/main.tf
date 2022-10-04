provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "argocd_namespace" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  chart      = "argocd"
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"

  set {
    name  = "service.type"
    value = "NodePort"
  }
}