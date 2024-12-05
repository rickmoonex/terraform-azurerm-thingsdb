locals {
  caddy_proxy_fqdn = var.http_api.proxy_dns_name != null ? var.http_api.proxy_dns_name : "${var.name}.${var.resource_group.location}.azurecontainer.io"
  caddyfile_content = templatefile("${path.module}/caddyfile.tftpl", {
    fqdn      = local.caddy_proxy_fqdn
    port      = 9210
    ws_enable = var.http_api.enable_websockets
    ws_port   = 9270
  })
  local_caddyfile_path = "${path.module}/Caddyfile"
  caddy_http_port = var.http_api.allow_http == false ? [] : [{
    port     = 80
    protocol = "TCP"
  }]
  caddy_https_port = var.http_api.allow_https == false ? [] : [{
    port     = 443
    protocol = "TCP"
  }]
  caddy_container_ports = concat(local.caddy_http_port, local.caddy_https_port)
}

resource "azurerm_storage_share" "proxy_caddyfile" {
  count              = var.http_api.enable == true ? 1 : 0
  name               = "proxy-caddyfile"
  storage_account_id = azurerm_storage_account.data.id
  quota              = 1
}

resource "local_file" "caddyfile" {
  count    = var.http_api.enable == true ? 1 : 0
  content  = local.caddyfile_content
  filename = local.local_caddyfile_path
}

resource "azurerm_storage_share_file" "caddyfile" {
  count            = var.http_api.enable == true ? 1 : 0
  name             = "Caddyfile"
  storage_share_id = azurerm_storage_share.proxy_caddyfile[count.index].url
  source           = local_file.caddyfile[count.index].filename
  content_md5      = local_file.caddyfile[count.index].content_md5
}
