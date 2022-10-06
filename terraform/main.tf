provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "argo-cd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argo-cd" {
  chart      = "argo-cd"
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  version = "5.5.8"
  namespace = kubernetes_namespace.argo-cd.metadata.0.name
  set {
    name  = "service.type"
    value = "NodePort"
  }
}