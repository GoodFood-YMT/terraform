# PostgreSQL
resource "azurerm_postgresql_server" "pgsql" {
  name                = "pgsql-authentification-${var.project_name}${var.environment_suffix}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  administrator_login          = data.azurerm_key_vault_secret.db-login.value
  administrator_login_password = data.azurerm_key_vault_secret.db-password.value

  sku_name   = "GP_Gen5_4"
  version    = "11"
  storage_mb = 5120

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = false

  public_network_access_enabled    = true
  ssl_enforcement_enabled          = false
  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
}

resource "azurerm_postgresql_firewall_rule" "pgsql" {
  name                = "AllowAzureServices"
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.pgsql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# Webapp
resource "azurerm_service_plan" "app-plan" {
  name                = "plan-authentification-${var.project_name}${var.environment_suffix}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "webapp" {
  name                = "web-authentification-${var.project_name}${var.environment_suffix}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.app-plan.id

  site_config {
    app_command_line = "npm run start"

    application_stack {
      node_version = "16-lts"
    }
  }


  app_settings = {
    "PORT"             = var.webapp_port
    "HOST"             = "0.0.0.0"
    "APP_KEY"          = var.webapp_key
    "DRIVE_DISK"       = "local"
    "DB_CONNECTION"    = "pg"
    "PG_HOST"          = azurerm_postgresql_server.pgsql.fqdn
    "PG_USER"          = "${data.azurerm_key_vault_secret.db-login.value}@${azurerm_postgresql_server.pgsql.name}"
    "PG_PASSWORD"      = data.azurerm_key_vault_secret.db-password.value
    "PG_DB_NAME"       = "postgres"
    "PG_PORT"          = 5432
    "REDIS_CONNECTION" = "local"
    "REDIS_HOST"       = azurerm_redis_cache.redis.hostname
    "REDIS_PORT"       = azurerm_redis_cache.redis.port
    "REDIS_PASSWORD"   = ""
  }
}

# Redis
resource "azurerm_redis_cache" "redis" {
  name                = "redis-authentification-${var.project_name}${var.environment_suffix}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  capacity            = 2
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {}
}

resource "azurerm_redis_firewall_rule" "redis" {
  name                = "AllowAzureServices"
  redis_cache_name    = azurerm_redis_cache.redis.name
  resource_group_name = data.azurerm_resource_group.rg.name
  start_ip            = "0.0.0.0"
  end_ip              = "0.0.0.0"
}

