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
    name  = "server.service.type"
    value = "LoadBalancer"
  }
}

data "kubectl_file_documents" "nginx_controller" {
  content = file("../tools/nginx_controller.yaml")
}

resource "kubectl_manifest" "nginx_controller_apply" {
  yaml_body = data.kubectl_file_documents.nginx_controller.content
}

data "kubectl_file_documents" "loki" {
  content = file("../tools/loki.yaml")
}

resource "kubectl_manifest" "loki_apply" {
  yaml_body = data.kubectl_file_documents.loki.content
}