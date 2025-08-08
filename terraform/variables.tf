variable "location" {
  description = "Azure region"
  default     = "East US"
}

variable "environment" {
  description = "Environment name"
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  default     = "policytest"
}

variable "allowed_locations" {
  description = "List of allowed Azure locations"
  type        = list(string)
}
