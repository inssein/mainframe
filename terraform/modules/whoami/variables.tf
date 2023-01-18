variable "name" {
  type        = string
  default     = "whoami"
  description = "name of the whoami service"
}

variable "namespace_name" {
  type        = string
  default     = "default"
  description = "name of the k8s namespace to deploy the service to"
}

variable "num_replicas" {
  type        = number
  default     = 1
  description = "number of nodes the service should spin up"
}

variable "ingress_class_name" {
  type        = string
  default     = ""
  description = "name of the k8s ingress class"
}

variable "tls_secret_name" {
  type        = string
  default     = ""
  description = "name of the k8s tls secret"
}

variable "host" {
  type        = string
  default     = ""
  description = "name of the hostname that the service should be exposed on"
}