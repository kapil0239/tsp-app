# SQL Database Alerts
# Using the same action group for consistency

# Alert: SQL Database CPU Usage
resource "azurerm_monitor_metric_alert" "sql_cpu_percentage" {
  name                = "sql-cpu-percentage-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_mssql_database.main.id]
  description         = "Alert when SQL database CPU usage exceeds threshold"
  severity            = 2
  enabled             = true
  auto_mitigate       = true
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 50 # 80% CPU
  }

  action {
    action_group_id = azurerm_monitor_action_group.webapp_alerts.id
  }

  tags = {
    environment = var.environment
  }
}

# Alert: SQL Database DTU Percentage (for DTU-based tiers)
resource "azurerm_monitor_metric_alert" "sql_dtu_percentage" {
  name                = "sql-dtu-percentage-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_mssql_database.main.id]
  description         = "Alert when SQL database DTU usage exceeds threshold"
  severity            = 2
  enabled             = true
  auto_mitigate       = true
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "dtu_consumption_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 50 # 80% DTU
  }

  action {
    action_group_id = azurerm_monitor_action_group.webapp_alerts.id
  }

  tags = {
    environment = var.environment
  }
}

# Alert: SQL Database Storage Usage
resource "azurerm_monitor_metric_alert" "sql_storage_percentage" {
  name                = "sql-storage-percentage-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_mssql_database.main.id]
  description         = "Alert when SQL database storage usage exceeds threshold"
  severity            = 2
  enabled             = true
  auto_mitigate       = true
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "storage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 25 # 85% storage
  }

  action {
    action_group_id = azurerm_monitor_action_group.webapp_alerts.id
  }

  tags = {
    environment = var.environment
  }
}

# Alert: SQL Database Connection Count
resource "azurerm_monitor_metric_alert" "sql_connection_count" {
  name                = "sql-connection-count-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_mssql_database.main.id]
  description         = "Alert when SQL database connection count exceeds threshold"
  severity            = 2
  enabled             = true
  auto_mitigate       = true
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "connection_successful"
    aggregation      = "Total"
    operator         = "LessThan"
    threshold        = 1 # Less than 1 successful connection (possible issue)
  }

  action {
    action_group_id = azurerm_monitor_action_group.webapp_alerts.id
  }

  tags = {
    environment = var.environment
  }
}

# Alert: SQL Database Failed Connections
resource "azurerm_monitor_metric_alert" "sql_failed_connections" {
  name                = "sql-failed-connections-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_mssql_database.main.id]
  description         = "Alert when SQL database failed connections exceed threshold"
  severity            = 1
  enabled             = true
  auto_mitigate       = true
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "connection_failed"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 2 # More than 5 failed connections
  }

  action {
    action_group_id = azurerm_monitor_action_group.webapp_alerts.id
  }

  tags = {
    environment = var.environment
  }
}

# Alert: SQL Database Deadlocks
resource "azurerm_monitor_metric_alert" "sql_deadlocks" {
  name                = "sql-deadlocks-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_mssql_database.main.id]
  description         = "Alert when SQL database deadlocks occur"
  severity            = 2
  enabled             = true
  auto_mitigate       = true
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "deadlock"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 0 # Any deadlocks
  }

  action {
    action_group_id = azurerm_monitor_action_group.webapp_alerts.id
  }

  tags = {
    environment = var.environment
  }
}

# Alert: SQL Database Blocked Queries
resource "azurerm_monitor_metric_alert" "sql_blocked_queries" {
  name                = "sql-blocked-queries-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_mssql_database.main.id]
  description         = "Alert when SQL database has blocked queries"
  severity            = 2
  enabled             = true
  auto_mitigate       = true
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "blocked_by_firewall"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 0 # Any blocked queries
  }

  action {
    action_group_id = azurerm_monitor_action_group.webapp_alerts.id
  }

  tags = {
    environment = var.environment
  }
}

# Alert: SQL Database Data IO Percentage
resource "azurerm_monitor_metric_alert" "sql_data_io_percentage" {
  name                = "sql-data-io-percentage-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_mssql_database.main.id]
  description         = "Alert when SQL database data IO usage exceeds threshold"
  severity            = 2
  enabled             = true
  auto_mitigate       = true
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "physical_data_read_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 30 # 80% data IO
  }

  action {
    action_group_id = azurerm_monitor_action_group.webapp_alerts.id
  }

  tags = {
    environment = var.environment
  }
}

# Alert: SQL Database Log IO Percentage
resource "azurerm_monitor_metric_alert" "sql_log_io_percentage" {
  name                = "sql-log-io-percentage-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_mssql_database.main.id]
  description         = "Alert when SQL database log IO usage exceeds threshold"
  severity            = 2
  enabled             = true
  auto_mitigate       = true
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "log_write_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 20 # 80% log IO
  }

  action {
    action_group_id = azurerm_monitor_action_group.webapp_alerts.id
  }

  tags = {
    environment = var.environment
  }
}

# Alert: SQL Database Worker Percentage
resource "azurerm_monitor_metric_alert" "sql_worker_percentage" {
  name                = "sql-worker-percentage-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_mssql_database.main.id]
  description         = "Alert when SQL database worker percentage exceeds threshold"
  severity            = 2
  enabled             = true
  auto_mitigate       = true
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "workers_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 30 # 80% workers
  }

  action {
    action_group_id = azurerm_monitor_action_group.webapp_alerts.id
  }

  tags = {
    environment = var.environment
  }
}

# Alert: SQL Database Sessions Percentage
resource "azurerm_monitor_metric_alert" "sql_sessions_percentage" {
  name                = "sql-sessions-percentage-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_mssql_database.main.id]
  description         = "Alert when SQL database sessions percentage exceeds threshold"
  severity            = 2
  enabled             = true
  auto_mitigate       = true
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "sessions_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 30 # 80% sessions
  }

  action {
    action_group_id = azurerm_monitor_action_group.webapp_alerts.id
  }

  tags = {
    environment = var.environment
  }
}

# Alert: SQL Server Firewall Blocked Connections
# resource "azurerm_monitor_metric_alert" "sql_firewall_blocked" {
#   name                = "sql-firewall-blocked-${var.environment}"
#   resource_group_name = azurerm_resource_group.main.name
#   scopes              = [azurerm_mssql_server.main.id]
#   description         = "Alert when SQL server firewall blocks connections"
#   severity            = 1
#   enabled             = true
#   auto_mitigate       = true
#   frequency           = "PT1M"
#   window_size         = "PT5M"

#   criteria {
#     metric_namespace = "Microsoft.Sql/servers"
#     metric_name      = "blocked_by_firewall"
#     aggregation      = "Total"
#     operator         = "GreaterThan"
#     threshold        = 0 # Any blocked connections
#   }

#   action {
#     action_group_id = azurerm_monitor_action_group.webapp_alerts.id
#   }

#   tags = {
#     environment = var.environment
#   }
# }

