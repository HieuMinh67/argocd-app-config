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

  set {
    name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal"
    value = "true"
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

resource "kubectl_manifest" "loki" {
  yaml_body = file("${path.module}/tools/loki.yaml")
}

resource "kubectl_manifest" "grafana" {
  yaml_body = file("${path.module}/tools/grafana.yaml")
}

resource "kubernetes_config_map" "prom_configmap_apply" {
  depends_on = [helm_release.argo-cd]
  metadata {
    name = "grafana-cluster-dashboard"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = ""
    }
  }

  data = {
    "grafana-cluster-dashboard" = file("${path.module}/tools/prometheus_dashboard.json")
  }
}

resource "kubernetes_manifest" "loki_configmap_apply" {
  manifest = yamldecode(templatefile("${path.module}/tools/configmap.yaml", {
    name      = "grafana-log-dashboard"
    filename  = "loki_dashboard"
    data      = file("${path.module}/tools/loki_dashboard.json")
  }))
}
