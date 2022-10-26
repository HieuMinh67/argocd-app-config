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

resource "helm_release" "loki-stack" {
  chart = "loki-stack"
  name  = "loki-stack"
  repository = "https://grafana.github.io/helm-charts"

  version = "2.8.3"
  namespace = kubernetes_namespace.monitoring.metadata.0.name

  set {
    name  = "grafana.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.server.persistentVolume.enabled"
    value = "false"
  }

  set {
    name  = "prometheus.alertmanager.persistentVolume.enabled"
    value = "false"
  }

  set {
    name  = "grafana.service.type"
    value = "LoadBalancer"
  }
}


data "kubectl_file_documents" "todo-app" {
  content = file("../application.yaml")
}

resource "kubectl_manifest" "nginx_controller_apply" {
  yaml_body = data.kubectl_file_documents.todo-app.content
}

#data "kubectl_file_documents" "nginx_controller" {
#  content = file("../tools/nginx_controller.yaml")
#}
#
#resource "kubectl_manifest" "nginx_controller_apply" {
#  yaml_body = data.kubectl_file_documents.nginx_controller.content
#}

#data "kubectl_file_documents" "loki" {
#  content = file("../tools/loki.yaml")
#}
#
#resource "kubectl_manifest" "loki_apply" {
#  yaml_body = data.kubectl_file_documents.loki.content
#}