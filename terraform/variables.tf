variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "autodecisionmaker"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 8080
}

variable "container_cpu" {
  description = "ECS task CPU"
  type        = string
  default     = "256"
}

variable "container_memory" {
  description = "ECS task memory in MB"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "container_image" {
  description = "Container image URI"
  type        = string
}

variable "enable_autoscaling" {
  description = "Enable autoscaling for ECS"
  type        = bool
  default     = true
}

variable "min_capacity" {
  description = "Minimum number of tasks"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of tasks"
  type        = number
  default     = 3
}

# Paths to PEM encoded certificate files generated with OpenSSL. If certificate_body_path is set (non-empty),
# Terraform will import the certificate into ACM and create an HTTPS listener on the ALB.
variable "certificate_body_path" {
  description = "Local path to certificate PEM file (public cert). Leave empty to skip importing a certificate."
  type        = string
  default     = ""
}

variable "private_key_path" {
  description = "Local path to private key PEM file corresponding to the certificate. Required when certificate_body_path is provided."
  type        = string
  default     = ""
}

variable "certificate_chain_path" {
  description = "Local path to certificate chain PEM file (optional)."
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Domain name for the certificate (e.g. example.com). If empty, app_name will be used — replace with your actual domain when importing a valid cert."
  type        = string
  default     = ""
}
