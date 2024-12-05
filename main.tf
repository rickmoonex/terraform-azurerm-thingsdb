locals {
  image_version = var.thingsdb_version == null ? "latest" : var.thingsdb_version

  default_ports = [
    {
      port     = var.client_listen_port
      protocol = "TCP"
    }
  ]
  ports = concat(local.default_ports, )

  storage_account_name = var.storage_account_name != null ? var.storage_account_name : "${var.name}data"
}

resource "azurerm_storage_account" "data" {
  name                     = local.storage_account_name
  resource_group_name      = var.resource_group.name
  location                 = var.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_share" "data" {
  name               = "data"
  storage_account_id = azurerm_storage_account.data.id
  quota              = 100
}

resource "azurerm_storage_share" "modules" {
  name               = "modules"
  storage_account_id = azurerm_storage_account.data.id
  quota              = 10
}

resource "azurerm_container_group" "containers" {
  name                = var.name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  ip_address_type = var.ip_address_type
  subnet_ids      = var.subnet_ids
  dns_name_label  = var.dns_name_label

  os_type = "Linux"

  image_registry_credential {
    username = var.registry_credential.username
    password = var.registry_credential.password
    server   = var.registry_credential.server
  }

  container {
    name   = "thingsdb"
    image  = "ghcr.io/thingsdb/node:${local.image_version}"
    cpu    = var.cpu_cores
    memory = var.memory

    dynamic "ports" {
      for_each = local.ports
      content {
        port     = ports.value["port"]
        protocol = ports.value["protocol"]
      }
    }

    volume {
      name                 = "data"
      mount_path           = "/data"
      storage_account_name = azurerm_storage_account.data.name
      storage_account_key  = azurerm_storage_account.data.primary_access_key
      share_name           = azurerm_storage_share.data.name
    }

    volume {
      name                 = "modules"
      mount_path           = "/modules"
      storage_account_name = azurerm_storage_account.data.name
      storage_account_key  = azurerm_storage_account.data.primary_access_key
      share_name           = azurerm_storage_share.modules.name
    }

    environment_variables = {
      THINGSDB_HTTP_STATUS_PORT = "8080"
      THINGSDB_HTTP_API_PORT    = "9210"
      THINGSDB_WS_PORT          = "9270"
    }

    liveness_probe {
      http_get {
        path   = "/healthy"
        port   = 8080
        scheme = "http"
      }
      initial_delay_seconds = 3
    }

    readiness_probe {
      http_get {
        path   = "/ready"
        port   = 8080
        scheme = "http"
      }
      initial_delay_seconds = 3
    }

    commands = ["thingsdb", "--init"]
  }

  dynamic "container" {
    for_each = var.http_api.enable == true ? [true] : []
    content {
      name   = "caddy-proxy"
      image  = var.caddy_image != null ? var.caddy_image : "caddy:2.6"
      cpu    = 1
      memory = 1

      dynamic "ports" {
        for_each = local.caddy_container_ports
        content {
          port     = ports.value["port"]
          protocol = ports.value["protocol"]
        }
      }

      volume {
        name                 = "proxy-caddyfile"
        mount_path           = "/etc/caddy"
        storage_account_name = azurerm_storage_account.data.name
        storage_account_key  = azurerm_storage_account.data.primary_access_key
        share_name           = azurerm_storage_share.proxy_caddyfile[0].name
      }
    }
  }
}
