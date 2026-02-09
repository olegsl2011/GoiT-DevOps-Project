variable "cluster_name" {
  description = "EKS cluster name (optional, used for naming/labels)"
  type        = string
  default     = null
}

variable "namespace" {
  description = "Namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "chart_version" {
  description = "Optional Helm chart version for kube-prometheus-stack"
  type        = string
  default     = null
}

variable "release_name" {
  description = "Helm release name"
  type        = string
  default     = "kube-prometheus-stack"
}