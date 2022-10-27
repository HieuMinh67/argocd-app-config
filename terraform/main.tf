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

resource "helm_release" "argocd-image-updater" {
  chart = "argocd-image-updater"
  name  = "argocd-image-updater"
  repository = "https://argoproj.github.io/argo-helm"

  version = "0.8.1"
  namespace = kubernetes_namespace.argo-cd.metadata.0.name
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}


resource "kubectl_manifest" "todo-app_apply" {
  yaml_body = file("../application.yaml")
}

#data "kubectl_file_documents" "nginx_controller" {
#  content = file("../tools/nginx_controller.yaml")
#}
#
#resource "kubectl_manifest" "nginx_controller_apply" {
#  yaml_body = data.kubectl_file_documents.nginx_controller.content
#}

resource "kubectl_manifest" "loki_apply" {
  yaml_body = file("${path.module}/tools/loki.yaml")
}

resource "kubectl_manifest" "loki_configmap_apply" {
  yaml_body = file("${path.module}/tools/loki_dashboard.yaml")
}

resource "kubectl_manifest" "prom_configmap_apply" {
  yaml_body = file("${path.module}/tools/prometheus_dashboard.yaml")
}