variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West US"
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


# variables.tf additions

# ACR SKU: Basic, Standard, Premium (Premium required for Private Endpoint)
variable "acr_sku" {
  type        = string
  default     = "Basic"
  description = "Azure Container Registry SKU. Use Premium if enabling private endpoint."
}

# Enable admin user (optional). Prefer role assignments in CI/CD over admin creds.
variable "acr_admin_enabled" {
  type    = bool
  default = false
}

# Optional: create a Private Endpoint for ACR (requires Premium)
variable "acr_enable_private_endpoint" {
  type        = bool
  default     = false
  description = "If true, creates a private endpoint for ACR; requires acr_sku=Premium."
}
