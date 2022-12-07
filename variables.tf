#######################
## Standard variables
#######################

variable "cluster_name" {
  type = string
}

variable "base_domain" {
  type = string
}

variable "argocd_namespace" {
  type = string
}

variable "target_revision" {
  description = "Override of target revision of the application chart."
  type        = string
  default     = "v1.1.0-alpha.1" # x-release-please-version
}

variable "cluster_issuer" {
  type    = string
  default = "ca-issuer"
}

variable "namespace" {
  type    = string
  default = "grafana"
}

variable "helm_values" {
  description = "Helm values, passed as a list of HCL structures."
  type        = any
  default     = []
}

variable "dependency_ids" {
  type = map(string)

  default = {}
}

#######################
## Module variables
#######################

variable "grafana" {
  description = "Grafana settings"
  type        = any
  default     = {}
}
