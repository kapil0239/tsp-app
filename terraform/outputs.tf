output "resource_group_name" {
  value       = azurerm_resource_group.main.name
  description = "Resource Group name"
}

output "aks_cluster_name" {
  value       = azurerm_kubernetes_cluster.main.name
  description = "AKS cluster name"
}

output "sql_server_name" {
  value       = azurerm_mssql_server.main.name
  description = "SQL Server name"
}

output "sql_database_name" {
  value       = azurerm_mssql_database.main.name
  description = "SQL Database name"
}

output "webapp_name" {
  value       = azurerm_linux_web_app.main.name
  description = "Web App name"
}

output "webapp_url" {
  value       = "https://${azurerm_linux_web_app.main.default_hostname}"
  description = "Web App URL"
}

# output "sql_private_endpoint_ip" {
#   value       = azurerm_private_endpoint.sql.private_service_connection[0].private_ip_address
#   description = "SQL Server private IP"
# }

output "vnet_name" {
  value       = azurerm_virtual_network.main.name
  description = "Virtual Network name"
}

output "aks_get_credentials_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}"
}

# output "sql_server_fqdn" {
#   value = azurerm_private_endpoint.sql.private_service_connection[0].private_ip_address
# }


output "acr_name" {
  value       = azurerm_container_registry.acr.name
  description = "ACR registry name (use for az acr login, docker tagging)."
}

output "acr_login_server" {
  value       = azurerm_container_registry.acr.login_server
  description = "ACR login server URL (e.g., acrname.azurecr.io)."
}

output "acr_id" {
  value       = azurerm_container_registry.acr.id
  description = "ACR resource ID."
}

# Optional visibility for the kubelet identity
output "aks_kubelet_object_id" {
  value       = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  description = "AKS kubelet managed identity object ID used for AcrPull role assignment."
}
