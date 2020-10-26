resource "helm_release" "nginx_ingress" {
  depends_on = [
    helm_release.external_dns
  ]
  name       = "nginx-ingress"
  namespace  = "kube-system"
  repository = "stable"
  chart      = "nginx-ingress"
  set {
    name  = "rbac.create"
    value = "true"
  }
  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }
}

resource "helm_release" "external_dns" {
  depends_on = [
    kubernetes_secret.external_dns_credentials
  ]
  name       = "external-dns"
  namespace  = "kube-system"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  set {
    name  = "provider"
    value = "google"
  }
  set {
    name  = "google.project"
    value = var.project_name
  }
  set {
    name  = "google.serviceAccountSecret"
    value = kubernetes_secret.external_dns_credentials.metadata[0].name
  }
  set {
    name  = "policy"
    value = "sync"
  }
}

resource "kubernetes_secret" "external_dns_credentials" {
  depends_on = [
    google_container_node_pool.primary_nodes
  ]
  metadata {
    name      = "external-dns-credentials"
    namespace = "kube-system"
    labels = {
      "sensitive" = "true"
    }
  }
  data = {
    "credentials.json" = file("${path.cwd}/account.json")
  }
}

resource "kubernetes_namespace" "cert_manager" {
  depends_on = [
    google_container_node_pool.primary_nodes
  ]
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  depends_on = [
    kubernetes_namespace.cert_manager,
  ]
  name       = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubectl_manifest" "issuer" {
  depends_on = [
    helm_release.cert_manager
  ]
  yaml_body = file("${path.cwd}/manifests/issuer.yaml")
}

resource "kubectl_manifest" "echo" {
  depends_on = [
    google_container_node_pool.primary_nodes
  ]
  yaml_body = file("${path.cwd}/manifests/echo.yaml")
}
