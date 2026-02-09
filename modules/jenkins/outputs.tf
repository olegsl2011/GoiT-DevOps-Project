locals {
  jenkins_lb_hostname = try(data.kubernetes_service.jenkins.status[0].load_balancer[0].ingress[0].hostname, null)
  jenkins_lb_ip       = try(data.kubernetes_service.jenkins.status[0].load_balancer[0].ingress[0].ip, null)

  # якщо hostname є — беремо його, інакше беремо ip (може бути теж null)
  jenkins_lb_addr = (
    local.jenkins_lb_hostname != null && local.jenkins_lb_hostname != ""
  ) ? local.jenkins_lb_hostname : local.jenkins_lb_ip
}

output "jenkins_url" {
  description = "Jenkins URL if Service type is LoadBalancer (otherwise null)."
  value       = local.jenkins_lb_addr != null ? "http://${local.jenkins_lb_addr}" : null
}

output "jenkins_port_forward" {
  description = "Use this if jenkins_url is null."
  value       = "kubectl -n ${var.namespace} port-forward svc/jenkins 8080:8080"
}

output "jenkins_admin_password" {
  description = "Jenkins admin password"
  value       = var.jenkins_admin_password
  sensitive   = true
}

output "jenkins_namespace" {
  description = "Jenkins namespace"
  value       = kubernetes_namespace.jenkins.metadata[0].name
}

output "jenkins_service_account" {
  description = "Jenkins service account name"
  value       = kubernetes_service_account.jenkins.metadata[0].name
}

data "kubernetes_service" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }
  depends_on = [helm_release.jenkins]
}