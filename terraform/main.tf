# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-tsp-${var.environment}"
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-tsp-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Subnets
resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "webapp" {
  name                 = "snet-webapp"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "webapp-delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-pe"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Private DNS Zones
# resource "azurerm_private_dns_zone" "sql" {
#   name                = "privatelink.database.windows.net"
#   resource_group_name = azurerm_resource_group.main.name
# }

# resource "azurerm_private_dns_zone" "webapp" {
#   name                = "privatelink.azurewebsites.net"
#   resource_group_name = azurerm_resource_group.main.name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
#   name                  = "sql-vnet-link"
#   resource_group_name   = azurerm_resource_group.main.name
#   private_dns_zone_name = azurerm_private_dns_zone.sql.name
#   virtual_network_id    = azurerm_virtual_network.main.id
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "webapp" {
#   name                  = "webapp-vnet-link"
#   resource_group_name   = azurerm_resource_group.main.name
#   private_dns_zone_name = azurerm_private_dns_zone.webapp.name
#   virtual_network_id    = azurerm_virtual_network.main.id
# }

# Azure SQL Server
resource "azurerm_mssql_server" "main" {
  name                          = "sql-tsp-${var.environment}-${random_string.suffix.result}"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  version                       = "12.0"
  administrator_login           = "sqladmin"
  administrator_login_password  = var.sql_admin_password
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true
}

resource "azurerm_mssql_database" "main" {
  name           = "sqldb-tsp"
  server_id      = azurerm_mssql_server.main.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  sku_name       = "S0"
  zone_redundant = false
}

# SQL Private Endpoint
# resource "azurerm_private_endpoint" "sql" {
#   name                = "pe-sql-${var.environment}"
#   location            = azurerm_resource_group.main.location
#   resource_group_name = azurerm_resource_group.main.name
#   subnet_id           = azurerm_subnet.private_endpoints.id

#   private_service_connection {
#     name                           = "psc-sql"
#     private_connection_resource_id = azurerm_mssql_server.main.id
#     subresource_names              = ["sqlServer"]
#     is_manual_connection           = false
#   }

#   private_dns_zone_group {
#     name                 = "sql-dns-zone-group"
#     private_dns_zone_ids = [azurerm_private_dns_zone.sql.id]
#   }
# }

# AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                    = "aks-tsp-${var.environment}"
  location                = azurerm_resource_group.main.location
  resource_group_name     = azurerm_resource_group.main.name
  dns_prefix              = "akstsp${var.environment}"
  private_cluster_enabled = false

  default_node_pool {
    name           = "default"
    node_count     = 2
    vm_size        = "Standard_D2s_v3"
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = "10.1.0.0/16"
    dns_service_ip = "10.1.0.10"
  }
  
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "asp-tsp-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

# Web App
resource "azurerm_linux_web_app" "main" {
  name                = "app-tsp-frontend-${var.environment}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_service_plan.main.location
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true

  site_config {
    always_on = true
    application_stack {
      node_version = "18-lts"
    }
  }

  app_settings = {
    "REACT_APP_API_URL" = "http://${azurerm_kubernetes_cluster.main.private_fqdn}"
  }

  #virtual_network_subnet_id = azurerm_subnet.webapp.id
}

# Random suffix for unique names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}



# ----------------------------
# Azure Container Registry
# ----------------------------
resource "azurerm_container_registry" "acr" {
  name                = "acrtsp${var.environment}${random_string.suffix.result}" # alphanumeric only
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled
}

# ---------------------------------------------------------
# Grant AKS (kubelet identity) permission to pull from ACR
# ---------------------------------------------------------
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}


resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-analytics-tsp-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}