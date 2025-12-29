variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  #sensitive   = true
  default = "adminutgji89123!@#"
}

variable "aks_node_count" {
  description = "Number of AKS nodes"
  type        = number
  default     = 2
}

variable "aks_node_size" {
  description = "AKS node VM size"
  type        = string
  default     = "Standard_D2s_v3"
}
