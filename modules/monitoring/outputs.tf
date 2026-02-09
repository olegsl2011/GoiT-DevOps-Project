output "namespace" {
  value = var.namespace
}

output "grafana_port_forward" {
  value = "kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n ${var.namespace}"
}

output "prometheus_port_forward" {
  value = "kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n ${var.namespace}"
}

output "grafana_service_name" {
  value = "${var.release_name}-grafana"
}